extends RefCounted

var displacement := 0.0
var velocity := 0.0
var stiffness := 92.0
var damping := 7.5

func step(dt: float, load_force: float) -> void:
	if dt <= 0.0:
		return
	var remaining := minf(dt, 0.1)
	while remaining > 0.0:
		var h := minf(remaining, 1.0 / 120.0)
		velocity += (stiffness * (load_force - displacement) - damping * velocity) * h
		displacement += velocity * h
		if displacement > 0.72:
			displacement = 0.72
			velocity = minf(velocity, 0.0)
		elif displacement < -0.23:
			displacement = -0.23
			velocity = maxf(velocity, 0.0)
		remaining -= h

func kick(strength: float) -> void:
	velocity = clampf(velocity + strength, -5.0, 6.0)
