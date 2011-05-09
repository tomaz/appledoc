//
//  GBExitCodes.h
//  appledoc
//
//  Created by Tomaz Kragelj on 9.05.11.
//  Copyright 2011 Gentle Bytes. All rights reserved.
//

#define GBEXIT_SUCCESS			0


#pragma mark - Exit code "domains"

#define GBEXIT_DOMAIN_ASSERT	0x100
#define GBEXIT_DOMAIN_LOG		0x200


#pragma mark - Internal inconsistencies codes

#define GBEXIT_ASSERT_GENERIC	GBEXIT_DOMAIN_ASSERT | 0x01


#pragma mark - Log based codes

#define GBEXIT_LOG_WARNING	GBEXIT_DOMAIN_LOG | 0x01
#define GBEXIT_LOG_ERROR	GBEXIT_DOMAIN_LOG | 0x02
#define GBEXIT_LOG_FATAL	GBEXIT_DOMAIN_LOG | 0x03
