"""Package only Git-listed public files; verify ZIP paths, roster, CRC and hashes."""
import argparse
import hashlib
import json
import subprocess
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]
PREFIX = "godot-mushroom-meadow/"
sha = lambda data: hashlib.sha256(data).hexdigest()


def verify_archive(path):
    with zipfile.ZipFile(path) as archive:
        if archive.testzip() is not None:
            raise ValueError("ZIP CRC failed")
        names = archive.namelist()
        if len(names) != len(set(n.casefold() for n in names)):
            raise ValueError("Duplicate ZIP paths")
        for name in names:
            parts = PurePosixPath(name)
            if not name.startswith(PREFIX) or parts.is_absolute() or ".." in parts.parts or ":" in name or "\\" in name:
                raise ValueError("Unsafe archive path: " + name)
        manifest = json.loads(archive.read(PREFIX + "PACKAGE-MANIFEST.json"))
        expected = {PREFIX + n for n in manifest["files"]} | {PREFIX + "PACKAGE-MANIFEST.json"}
        if set(names) != expected:
            raise ValueError("Archive file roster differs from manifest")
        for name, record in manifest["files"].items():
            data = archive.read(PREFIX + name)
            if len(data) != record["bytes"] or sha(data) != record["sha256"]:
                raise ValueError("Archive hash mismatch: " + name)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", default="1.0.0")
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    parser.add_argument("--engine-dir", type=Path)
    parser.add_argument("--verify", type=Path, help="Verify an existing archive and exit")
    args = parser.parse_args()
    if args.verify:
        manifest = verify_archive(args.verify)
        print(json.dumps({"ok": True, "files": len(manifest["files"]), "kind": manifest["kind"]}))
        return
    if not args.version.replace(".", "").isalnum():
        raise ValueError("Version must contain only letters, digits and dots")
    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode("utf-8").split("\0")
    files = {name: (ROOT / name).read_bytes() for name in tracked if name}
    for name in files:
        parts = PurePosixPath(name).parts
        if any(p in {".git", ".godot", "engine", "dist", "launch-logs", "node_modules"} for p in parts):
            raise ValueError("Non-public file was Git-listed: " + name)
        if name.endswith((".import", ".exe", ".zip", ".pem", ".key")) or PurePosixPath(name).name.startswith(".env"):
            raise ValueError("Forbidden source-package file: " + name)
    for required in ["project.godot", "scenes/meadow.tscn", "assets/fonts/NotoSansSC.ttf", "assets/fonts/OFL.txt", "LICENSE", "THIRD_PARTY_NOTICES.md", "tests/smoke.gd"]:
        if required not in files:
            raise ValueError("Missing required public file: " + required)
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    args.output.mkdir(parents=True, exist_ok=True)
    kinds = {"source": files}
    if args.engine_dir:
        portable = dict(files)
        for name in ["Godot_v4.7.2-stable_win64.exe", "Godot_v4.7.2-stable_win64_console.exe"]:
            portable["engine/" + name] = (args.engine_dir / name).read_bytes()
        for required in ["licenses/GODOT-LICENSE.txt", "licenses/GODOT-COPYRIGHT.txt"]:
            if required not in portable:
                raise ValueError("Bundled engine notice missing: " + required)
        kinds["windows-portable"] = portable
    checksums = []
    for kind, roster in kinds.items():
        filename = f"godot-mushroom-meadow-v{args.version}-{kind}.zip"
        archive_path = args.output / filename
        manifest = {"version": args.version, "kind": kind, "source_commit": commit,
                    "files": {n: {"bytes": len(data), "sha256": sha(data)} for n, data in sorted(roster.items())}}
        with zipfile.ZipFile(archive_path, "x", zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
            for name, data in sorted({**roster, "PACKAGE-MANIFEST.json": json.dumps(manifest, ensure_ascii=False, indent=2).encode("utf-8")}.items()):
                info = zipfile.ZipInfo(PREFIX + name, date_time=(2026, 10, 15, 0, 0, 0))
                info.external_attr = (0o100755 if name.endswith(".sh") else 0o100644) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(info, data)
        verify_archive(archive_path)
        checksums.append(sha(archive_path.read_bytes()) + "  " + filename)
        print(json.dumps({"file": filename, "bytes": archive_path.stat().st_size, "files": len(roster), "verified": True}))
    (args.output / "SHA256SUMS.txt").write_text("\n".join(checksums) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
