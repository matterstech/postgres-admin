EXTENSION = postgres_admin
DATA = $(filter-out $(wildcard sql/*--*.sql),$(wildcard sql/*.sql))

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
