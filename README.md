# Preflight Result Post-Processing with Open Policy Agent

This repository contains a proof-of-concept
[policy](./preflight_postprocess.rego) definition for using Open Policy Agent to
post-process a
[Preflight](https://github.com/redhat-openshift-ecosystem/openshift-preflight) result.
It allows a caller to ignore failures listed in Preflight results.

This PoC is intended for continuous integration demonstrations and use cases,
and is not used in any capacity for Certification.

Use of the code herein is at your own risk.

## How It Works

You feed the `opa` command your Preflight `result.json` as an **input** file,
and the [policy](./preflight_postprocess.rego) and a
[skip-config.json](#skip-configuration) as **data**. The `opa` command returns
its new take on the Preflight outcome.

## Simple Local Usage

Running this command:

```shell
opa eval \
  --input /path/to/preflight/result.json \
  --data /path/to/skip-config.json \
  --data preflight_postprocess.rego \
  data.preflight_postprocess
```

With this contents inside the **skip-config.json**:

```json
{
    "ignore_on_failure": ["RunAsNonRoot"]
}
```

Produces:

```rego
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "actual_skipped_failure_count": 1,
            "desired_skipped_failure_count": 1,
            "has_no_errors": true,
            "has_no_errors_pre_skip": true,
            "has_no_failures": true,
            "has_no_failures_pre_skip": false,
            "included_failure_count": 0,
            "included_failures": [],
            "raw_failure_count": 1,
            "skipped_failures": [
              {
                "check_url": "https://access.redhat.com/documentation/en-us/red_hat_software_certification/2024/html-single/red_hat_openshift_software_certification_policy_guide/index#assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction",
                "description": "Checking if container runs as the root user because a container that does not specify a non-root user will fail the automatic certification, and will be subject to a manual review before the container can be approved for publication",
                "elapsed_time": 0,
                "help": "Check RunAsNonRoot encountered an error. Please review the preflight.log file for more information.",
                "knowledgebase_url": "https://access.redhat.com/documentation/en-us/red_hat_software_certification/2024/html-single/red_hat_openshift_software_certification_policy_guide/index#assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction",
                "name": "RunAsNonRoot",
                "suggestion": "Indicate a specific USER in the dockerfile or containerfile"
              }
            ],
            "skips_select_failed_checks": true
          },
          "text": "data.preflight_postprocess",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}
```

You can see:

- The skip configuration defined 1 check to skip

- The Preflight result failed that check

- The post-processing determined that the Preflight result no longer has
  failures (per `has_no_failures`).

## Skip Configuration

The skip configuration is a simple JSON blob containing the check names to skip.
This is not a Preflight concept. This just feeds `opa` data to aid in
processing. The format is minimal, e.g.:

```json
{
    "ignore_on_failure": ["RunAsNonRoot"]
}
```

## Containerfile

You can build a containerfile containing this content for use in CI. It does not
define an entrypoint; it's only intended to serve as a scripting environment.

The image contains:

- `opa` pre-installed at the version listed within the Containerfile.
- The rego definition at `/preflight_postprocess.rego`
- A base/empty skip-config.json at `/skip-config.json`

To use this, mount your Preflight results into the container and process the
`opa` output fit your needs.