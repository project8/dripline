/*
 * dripline_c.cc
 *
 *  Created on: Jun 2, 2016
 *      Author: obla999
 */

#include "message.hh"
#include "service.hh"

#include "param.hh"

extern "C"
{
    #include "dripline.h"
}

service_c* setup_service_sendonly( char* a_broker )
{
    return reinterpret_cast< service_c* >( new dripline::service( std::string( a_broker ), 5672, "requests" ) );
}

retinfo* create_retinfo( int a_retmsg_size );


// Setters

void set_i( service_c* a_service, char* a_rk, int a_value )
{
    scarab::param_array* t_values = new scarab::param_array();
    t_values->push_back( new scarab::param_value( a_value ) );
    scarab::param_node* t_node = new scarab::param_node();
    t_node->add( "values", t_values );

    dripline::service* t_service = reinterpret_cast< dripline::service* >( a_service );

    dripline::request_ptr_t t_request = dripline::msg_request::create( t_node, dripline::op_t::set, a_rk, "", dripline::message::encoding::json );

    dripline::service::rr_pkg_ptr t_receive_reply = t_service.send( t_request );

    if( ! t_receive_reply->f_successful_send )
    {
        LERROR( mtlog, "Unable to send request" );
        f_return = RETURN_ERROR;
        return;
    }

    if( ! t_receive_reply->f_consumer_tag.empty() )  // this indicates that the reply queue was created, and we've started consuming on it; we should wait for a reply
    {
        LINFO( mtlog, "Waiting for a reply from the server; use ctrl-c to cancel" );

        // timed blocking call to wait for incoming message
        dripline::reply_ptr_t t_reply = t_service.wait_for_reply( t_receive_reply, t_broker_node.get_value< int >( "reply-timeout-ms" ) );

        if( t_reply )
        {
            LINFO( mtlog, "Response received" );

            const param_node* t_payload = &( t_reply->get_payload() );

            LINFO( mtlog, "Response from Mantis:\n" <<
                    "Return code: " << t_reply->get_return_code() << '\n' <<
                    "Return message: " << t_reply->return_msg() << '\n' <<
                    *t_payload );

            // optionally save "master-config" from the response
            if( t_save_node.size() != 0 )
            {
                if( t_save_node.has( "json" ) )
                {
                    scarab::path t_save_filename( scarab::expand_path( t_save_node.get_value( "json" ) ) );
                    const param_node* t_master_config_node = t_payload;
                    if( t_master_config_node == NULL )
                    {
                        LERROR( mtlog, "Payload is not present" );
                    }
                    else
                    {
                        param_output_json::write_file( *t_master_config_node, t_save_filename.string(), param_output_json::k_pretty );
                    }
                }
                else
                {
                    LERROR( mtlog, "Save instruction did not contain a valid file type");
                }

            }
        }
        else
        {
            LWARN( mtlog, "Timed out waiting for reply" );
        }
    }
}
void set_d( service_c* a_service, char* a_rk, double a_value );
void set_str( service_c* a_service, char* a_rk, char* a_str, int a_str_size );


// Getters

int get_i( service_c* a_service, char* a_rk, int a_retcode, retinfo* a_retinfo );
double get_d( service_c* a_service, char* a_rk, int a_retcode, retinfo* a_retinfo );
void get_str( service_c* a_service, char* a_rk, retinfo* a_retinfo, char* a_str, int a_str_size );


// Finishing

void destroy_service( service_c* a_service )
{
    delete reinterpret_cast< dripline::service* >( a_service );
}

void destroy_retinfo( retinfo* a_retinfo );


