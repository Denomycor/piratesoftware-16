## Unit tests for PolygonRandomPointGenerator.
## triangle_area() and random_triangle_point() are pure static math.
## get_random_point() requires instantiation (uses Geometry2D).
extends GutTest

# A simple square polygon: (0,0), (100,0), (100,100), (0,100)
var _square_polygon: PackedVector2Array = PackedVector2Array([
	Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)
])

# ------------------------------------------------------------------ triangle_area

func test_triangle_area_known_right_triangle() -> void:
	# Right triangle with legs 3 and 4 → area = 0.5 * 3 * 4 = 6
	var a := Vector2(0, 0)
	var b := Vector2(3, 0)
	var c := Vector2(0, 4)
	var area := PolygonRandomPointGenerator.triangle_area(a, b, c)
	assert_almost_eq(area, 6.0, 0.001)


func test_triangle_area_unit_triangle() -> void:
	var a := Vector2(0, 0)
	var b := Vector2(1, 0)
	var c := Vector2(0, 1)
	assert_almost_eq(PolygonRandomPointGenerator.triangle_area(a, b, c), 0.5, 0.001)


func test_triangle_area_is_always_positive() -> void:
	# Winding order shouldn't produce negative area
	var a := Vector2(0, 0)
	var b := Vector2(10, 5)
	var c := Vector2(5, 10)
	assert_gt(PolygonRandomPointGenerator.triangle_area(a, b, c), 0.0)


func test_triangle_area_collinear_points_is_zero() -> void:
	var a := Vector2(0, 0)
	var b := Vector2(5, 0)
	var c := Vector2(10, 0)
	assert_almost_eq(PolygonRandomPointGenerator.triangle_area(a, b, c), 0.0, 0.001)


# ------------------------------------------------------------------ random_triangle_point

func test_random_triangle_point_stays_inside_known_bounds() -> void:
	# For a right triangle in the positive quadrant, sampled points must have
	# x >= 0, y >= 0, and x + y <= 1 (unit simplex)
	var a := Vector2(0, 0)
	var b := Vector2(1, 0)
	var c := Vector2(0, 1)
	# Sample many times — all should satisfy the simplex constraint
	for _i in range(100):
		var p := PolygonRandomPointGenerator.random_triangle_point(a, b, c)
		assert_gte(p.x, -0.001, "x should be >= 0")
		assert_gte(p.y, -0.001, "y should be >= 0")
		assert_lte(p.x + p.y, 1.001, "x + y should be <= 1 inside the simplex")


# ------------------------------------------------------------------ get_random_point (instantiation required)

func test_get_random_point_is_inside_square_polygon() -> void:
	var gen := PolygonRandomPointGenerator.new(_square_polygon)
	# Sample 50 points — all should lie inside the [0,100]x[0,100] square
	for _i in range(50):
		var p := gen.get_random_point()
		assert_gte(p.x, -0.001, "x should be >= 0")
		assert_lte(p.x, 100.001, "x should be <= 100")
		assert_gte(p.y, -0.001, "y should be >= 0")
		assert_lte(p.y, 100.001, "y should be <= 100")


func test_get_random_point_returns_vector2() -> void:
	var gen := PolygonRandomPointGenerator.new(_square_polygon)
	var p := gen.get_random_point()
	assert_typeof(p, TYPE_VECTOR2)
