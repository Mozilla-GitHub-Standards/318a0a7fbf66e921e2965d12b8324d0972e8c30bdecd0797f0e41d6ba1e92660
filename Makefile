all: update-config allocate commit push

${CONFIG_DIR}:
	@git clone ${CONFIG_REPO} ${CONFIG_DIR}

update-config: ${CONFIG_DIR}
	@pushd ${CONFIG_DIR}; git pull; popd

config.json v1: ${CONFIG_DIR}
	@ln -sf ${CONFIG_DIR}/config.json .
	@ln -sf ${CONFIG_DIR}/v1 .

allocate: v1 config.json
	@python manage_jacuzzis.py && \
	python allocate.py --db ${DB_URL} > ${CONFIG_DIR}/allocate.log

commit: allocate
	@if [ -s ${CONFIG_DIR}/allocate.log ]; then \
		pushd ${CONFIG_DIR}; \
		git add -A v1 config.json; \
		git commit --author="allocator <no-reply@mozilla.com>" -q -F allocate.log; \
		popd; \
	fi

push: commit
	@pushd ${CONFIG_DIR}; git push -q origin; popd

.PHONY: allocate update-config commit push
