from octopus_day2.greeter import welcome


def test_welcome_with_name() -> None:
    assert welcome("Azure DevOps") == "Hello from Octopus Day 2, Azure DevOps!"


def test_welcome_defaults_to_world() -> None:
    assert welcome() == "Hello from Octopus Day 2, World!"


def test_welcome_trims_blank_name() -> None:
    assert welcome("   ") == "Hello from Octopus Day 2, World!"
