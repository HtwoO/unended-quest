# inject my local setting
include local.env
DEST_DIR := $(REMOTE_HOST):$(REMOTE_PATH)
SOURCE_DIR := $(LOCAL_PATH)

public: site
	rsync --archive --compress $(SOURCE_DIR) $(DEST_DIR)

site:
	hugo --cleanDestinationDir

test:
	hugo server
