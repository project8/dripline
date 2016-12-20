/*
 * dripline.h
 *
 *  Created on: Jun 2, 2016
 *      Author: obla999
 */

#ifndef DRIPLINE_C_DRIPLINE_H_
#define DRIPLINE_C_DRIPLINE_H_

struct service_c;  // opaque service pointer

struct retinfo
{
    int f_retcode;
    char* f_retmsg;
    int f_retmsg_size;
};

// Startup

service_c* setup_service_sendonly( char* a_broker );

retinfo* create_retinfo( int a_retmsg_size );


// Setters

void set_i( service_c* a_service, char* a_rk, int a_value );
void set_d( service_c* a_service, char* a_rk, double a_value );
void set_str( service_c* a_service, char* a_rk, char* a_str, int a_str_size );


// Getters

int get_i( service_c* a_service, char* a_rk, int a_retcode, retinfo* a_retinfo );
double get_d( service_c* a_service, char* a_rk, int a_retcode, retinfo* a_retinfo );
void get_str( service_c* a_service, char* a_rk, retinfo* a_retinfo, char* a_str, int a_str_size );


// Finishing

void destroy_service( service_c* a_service );

void destroy_retinfo( retinfo* a_retinfo );

#endif /* DRIPLINE_C_DRIPLINE_H_ */
