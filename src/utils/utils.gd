extends Object
class_name Utils


static func range_lerp(value: float, istart: float, istop: float, ostart: float, ostop: float) -> float:
	return ostart + (ostop - ostart) * (value) / (istop - istart)
