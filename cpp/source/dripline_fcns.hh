/*
 * dripline_fcns.hh
 *
 *  Created on: Jun 2, 2016
 *      Author: obla999
 */

#ifndef DRIPLINE_DRIPLINE_FCNS_HH_
#define DRIPLINE_DRIPLINE_FCNS_HH_

#include "param.hh"

#include "message.hh"


namespace dripline
{



    request_ptr_t create_run_request( const std::string& a_routing_key );
    request_ptr_t create_get_request( const std::string& a_routing_key );
    request_ptr_t create_set_request( const std::string& a_routing_key );
    request_ptr_t create_cmd_request( const std::string& a_routing_key );

}

#endif /* DRIPLINE_DRIPLINE_FCNS_HH_ */
