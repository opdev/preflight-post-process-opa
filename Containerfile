ARG OPA_VERSION=0.67.0

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ARG OPA_VERSION

LABEL name="Preflight Post Process" \
      vendor="The OpDev Team" \
      maintainer="The OpDev Team" \
      version="1" \
      summary="Post-processing Preflight results." \
      description="Provides opa cli and rego definitions for post-processing Preflight results." \
      url="https://github.com/opdev/preflight-post-process-opa"
COPY LICENSE /licenses/LICENSE
COPY preflight_postprocess.rego /preflight_postprocess.rego

# By default, skip-config.json is an empty config file. The user is expected to
# overwrite it, though this isn't a strict requirement.
COPY empty-skip-config.json /empty-skip-config.json
RUN ln -sf /empty-skip-config.json /skip-config.json

# Install `jq` and `opa`
RUN microdnf install -y jq \
	&& curl \
	--location \
	--output /usr/local/bin/opa \
	https://openpolicyagent.org/downloads/v${OPA_VERSION}/opa_linux_amd64_static \
	&& chmod 755 /usr/local/bin/opa \
	&& opa version
