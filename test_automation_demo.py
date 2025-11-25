"""
Demo test file to verify the automated test fix pipeline.
This file intentionally contains bugs to trigger the automation.
"""

def add_numbers(a, b):
    """Add two numbers together."""
    # Intentional bug: subtracts instead of adds
    return a - b  # This should be: return a + b


def multiply_numbers(a, b):
    """Multiply two numbers."""
    return a * b


def test_add_positive_numbers():
    """Test adding positive numbers - WILL FAIL."""
    result = add_numbers(2, 3)
    assert result == 5, f"Expected 5 but got {result}"


def test_add_negative_numbers():
    """Test adding negative numbers - WILL FAIL."""
    result = add_numbers(-2, -3)
    assert result == -5, f"Expected -5 but got {result}"


def test_add_zero():
    """Test adding zero - WILL FAIL."""
    result = add_numbers(5, 0)
    assert result == 5, f"Expected 5 but got {result}"


def test_multiply_numbers():
    """Test multiplying numbers - WILL PASS."""
    result = multiply_numbers(4, 5)
    assert result == 20, f"Expected 20 but got {result}"
