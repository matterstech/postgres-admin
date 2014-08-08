EXTENSION = postgres_admin
EXTVERSION = 1.0
FILES = $(wildcard sql/*--unpackaged.sql)
FINAL_FILE = sql/$(EXTENSION)--$(EXTVERSION).sql
DATA = sql/$(EXTENSION)--$(EXTVERSION).sql

PG_CONFIG = pg_config

VERSION     = $(shell $(PG_CONFIG) --version | awk '{print $$2}')
PGVER_MAJOR = $(shell echo $(VERSION) | awk -F. '{ print ($$1 + 0) }')
PGVER_MINOR = $(shell echo $(VERSION) | awk -F. '{ print ($$2 + 0) }')

all:
	cat $(FILES) > $(FINAL_FILE)

DATA = $(filter-out sql/$(EXTENSION)--unpackaged.sql,$(wildcard sql/*--*.sql)) sql/$(EXTENSION)--$(EXTVERSION).sql

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
