/*
 * Copyright (C) 2005 National Association of REALTORS(R)
 *
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, provided that the above copyright notice(s) and this
 * permission notice appear in all copies of the Software and that
 * both the above copyright notice(s) and this permission notice
 * appear in supporting documentation.
 */

#include "EzLogger.h"

using namespace odbcrets;
using std::string;

EzLogger::EzLogger() : mLevel(DEBUG) { }

EzLogger::~EzLogger()
{
}

void EzLogger::setLogLevel(Level level)
{
    mLevel = level;
}

void EzLogger::debug(string data)
{
    log(DEBUG, data);
}

void EzLogger::info(string data)
{
    log(INFO, data);
}

void EzLogger::warn(string data)
{
    log(WARN, data);
}

void EzLogger::error(string data)
{
    log(ERRORS, data);
}

void NullEzLogger::log(Level level, string data) { }

EzLoggerPtr NullEzLogger::sInstance;

EzLoggerPtr NullEzLogger::GetInstance()
{
    if (sInstance == 0)
    {
        sInstance.reset(new NullEzLogger());
    }

    return sInstance;
}
