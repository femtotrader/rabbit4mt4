#!/usr/bin/env python
import logging
import traceback
import logging.config
import pika
import sys
import argparse
import datetime

def get_logging_level_from_name(name):
    try:
        name = name.upper()
    except:
        name = "CRITICAL"
    
    level = logging.getLevelName(name)
    
    if isinstance(level, int):
        return(level)
    else:
        return(logging.CRITICAL)

def callback(ch, method, properties, body):
    try:
        routing_key = method.routing_key
        t_routing_key = routing_key.split(".")
        terminal_id = t_routing_key[0]
        level = get_logging_level_from_name(t_routing_key[-1])
        #logging.info("%s - %s" % (routing_key, body))
        logging.log(level, "%s - %s" % (terminal_id, body))
    except:
        logging.error(traceback.format_exc())

def main(args):
    connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
    channel = connection.channel()

    exchange = 'topic_logs'

    channel.exchange_declare(exchange=exchange,
                         type='topic')

    result = channel.queue_declare(exclusive=True)
    queue_name = result.method.queue

    binding_keys = args.binding_keys.split(',')

    for binding_key in binding_keys:
        channel.queue_bind(exchange=exchange,
                       queue=queue_name,
                       routing_key=binding_key)

    logging.info(' [*] Waiting for logs. To exit press CTRL+C')


    channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)

    channel.start_consuming()

if __name__ == '__main__':
    logging.config.fileConfig("logging.conf")
    
    logger = logging.getLogger("simpleExample")

    parser = argparse.ArgumentParser()
    parser.add_argument("--binding_keys", help="binding keys (use comma ',' to split several binding keys), default is '#' to receive any message, binding_key can be 'mt4_demo01_123456.events.logs.*.*' or 'mt4_demo01_123456.events.logs.main.debug', 'mt4_demo01_123456.events.logs.main.info', 'mt4_demo01_123456.events.logs.main.warning', 'mt4_demo01_123456.events.logs.main.error' or 'mt4_demo01_123456.events.logs.main.critical'", default="#")
    args = parser.parse_args()
    main(args)