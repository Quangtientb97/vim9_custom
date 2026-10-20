# Makefile Test Sample Fixture
opt.fsdb_all:
	@echo Parsing $@
	# Indented comment inside recipe
	@echo 'call fsdbDumpfile all.fsdb                                                     '  >> ${MAKE_DIR_TEMP}/sim.tcl
	@echo 'call fsdbDumpvars 0 hdx_cpucl_tb +all                                          '  >> ${MAKE_DIR_TEMP}/sim.tcl
	@echo '    -assert           \'                                                          >> ${MAKE_DIR_TEMP}/${RUN_FILE}
	@echo '    +access+rwc       \'                                                          >> ${MAKE_DIR_TEMP}/${RUN_FILE}
	@echo '    +fsdb+sva_success \'                                                          >> ${MAKE_DIR_TEMP}/${RUN_FILE}
	@echo "double quote with \"escaped\" contents" >> $(LOG_FILE)

clean:
	@rm -rf ${BUILD_DIR}
