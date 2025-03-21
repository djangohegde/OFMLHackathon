/*
 * BSD 2-Clause License
 *
 * Copyright (c) 2021-2023, Hewlett Packard Enterprise
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef SMARTREDIS_SROBJECT_H
#define SMARTREDIS_SROBJECT_H

#ifdef __cplusplus
#include <stdlib.h>
#include <string>
#include <vector>
#include "sr_enums.h"

///@file

namespace SmartRedis{

///@file
/*!
*   \brief The SRObject is a common base class for SmartRedis
*          objects that can represent a context for logging
*/
class SRObject
{
    public:

        /*!
        *   \brief SRObject constructor
        *   \param logging_name The name to prefix log entries with
        *          when logging with this as a context
        */
        SRObject(const std::string& logging_name);

        /*!
        *   \brief SRObject default destructor
        */
        virtual ~SRObject() = default;

        /*!
        *   \brief Conditionally log data if the logging level is high enough
        *   \param level Minimum logging level for data to be logged
        *   \param data Text of data to be logged
        */
        virtual void log_data(
            SRLoggingLevel level, const std::string& data) const;

        /*!
        *   \brief Conditionally log warning data if the logging level is
        *          high enough
        *   \param level Minimum logging level for data to be logged
        *   \param data Text of data to be logged
        */
        virtual void log_warning(
            SRLoggingLevel level, const std::string& data) const
        {
            log_data(level, "WARNING: " + data);
        }

        /*!
        *   \brief Conditionally log error data if the logging level is
        *          high enough
        *   \param level Minimum logging level for data to be logged
        *   \param data Text of data to be logged
        */
        virtual void log_error(
            SRLoggingLevel level, const std::string& data) const
        {
            log_data(level, "ERROR: " + data);
        }

        /*!
        *   \brief Retrieve the context for this object
        *   \returns The context for this object
        */
        virtual std::string get_context() const
        {
            return _lname;
        }

    private:

        /*!
        *   \brief The name prefix log entries with
        */
        std::string _lname;
};

} // namespace SmartRedis

#endif // __cplusplus
#endif // SMARTREDIS_SROBJECT_H
