package preflight_postprocess

import rego.v1

# Whether or not the asset is certified after all check skipping is applied.
# Note: This is disabled for now as we don't have a concept of "certified" when
# check-skipping is allowed like this.

# default certified := false

# certified if {
# 	has_no_errors
# 	has_no_failures
# }

# Whether the Preflight result has no errors after check-skipping is applied.
# Note: check-skipping for errors is currently not implemented.
default has_no_errors := false

has_no_errors if {
	is_array(input.results.errors)
	count(input.results.errors) = 0
}

# Whether the Preflight result has no failures after check-skipping is applied.
default has_no_failures := false

has_no_failures if {
	is_array(included_failures)
	included_failure_count = 0
}

# Details whether or not the user provided a skip configuration.
default skips_select_failed_checks := false

skips_select_failed_checks if {
	count(data.ignore_on_failure) > 0
}

# This is how many failures the user wanted to skip.
desired_skipped_failure_count := count(data.ignore_on_failure)

# The number of failures we actually skipped.
actual_skipped_failure_count := count(skipped_failures)

# The number of failures that were included (i.e. not skipped)
included_failure_count := count(included_failures)

# The failures that were not skipped
included_failures := [result | some result in input.results.failed; not result.name in data.ignore_on_failure]

# The failures that were skipped.
skipped_failures := [result | some result in input.results.failed; result.name in data.ignore_on_failure]

# Overall failure count before any skipping is applied.
raw_failure_count := count(input.results.failed)

# Failure and error count before anything else is applied
default has_no_errors_pre_skip := false

has_no_errors_pre_skip if {
	is_array(input.results.errors)
	count(input.results.errors) = 0
}

default has_no_failures_pre_skip := false

has_no_failures_pre_skip if {
	is_array(input.results.failed)
	count(input.results.failed) = 0
}
