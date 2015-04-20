#!/usr/bin/env python
import logging
import traceback
import logging.config
import pika
import sys
import argparse
import datetime
import json

#ToFix: add datetime when logging to console

def callback(ch, method, properties, body):
    #dt_now = datetime.datetime.now()
    #print(" [x] %s - %r:%r" % (dt_now, method.routing_key, body,))
    #logging.info("%r:%r" % (method.routing_key, body))
    try:
        logging.info("%s - %s" % (method.routing_key, body))
        message = json.loads(body)
        if args.nopretty:
            logging.info(message) # display without pretty print
        else:
            logging.info(json.dumps(message, sort_keys=True, indent=4, separators=(',', ': '))) # display with pretty print
        print("")
    except:
        logging.info(traceback.format_exc())

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

    logging.info(' [*] Waiting for ticks. To exit press CTRL+C')


    channel.basic_consume(callback,
                      queue=queue_name,
                      no_ack=True)

    channel.start_consuming()

if __name__ == '__main__':
    #logger = logging.getLogger() #getLogger(__name__)
    #logger = logging.getLogger(__name__)
    
    logging.config.fileConfig("logging.conf")
    
    logger = logging.getLogger("simpleExample")

    #logging.basicConfig(level=logging.DEBUG) # uncomment to see RabbitMQ logs
    #logging.basicConfig(level=logging.INFO)

    # Console handler
    #ch = logging.StreamHandler()
    #ch.setLevel(logging.INFO)
    #formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    #ch.setFormatter(formatter)
    #logger.addHandler(ch)
    
    # File handler
    #fh = logging.FileHandler('receive.log')
    #fh.setLevel(logging.INFO)
    #formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    #fh.setFormatter(formatter)
    #logger.addHandler(fh)

    parser = argparse.ArgumentParser()
    parser.add_argument("--binding_keys", help="binding keys (use comma ',' to split several binding keys), default is '#' to receive any message, binding_key can be 'mt4_demo01_123456.events.ticks.eurusd'", default="#")
    parser.add_argument("--nopretty", help="disable pretty print", action="store_true")
    args = parser.parse_args()
    main(args)