import math


def test_add():
    assert 1 + 1 == 2
def test_upper():
    assert "abc".upper() == "ABC"
def test_len():
    assert len([1,2,3]) == 3
def test_membership():
    assert 3 in {1,2,3}
def test_dict_get():
    assert {"a":1}.get("a") == 1
def test_float_close():
    assert math.isclose(0.1 + 0.2, 0.3, rel_tol=1e-9, abs_tol=1e-9)
def test_truthy():
    assert bool([42]) is True
# ---- 3 tests that FAIL (intentional) ----
def test_fail_math():
    assert 2 * 2 == 5
def test_fail_string():
    assert "Hello".islower()
def test_fail_contains():
    assert 5 in [1,2,3]
