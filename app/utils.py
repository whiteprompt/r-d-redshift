import logging

class Logger:
    def __init__(self):
        logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s', datefmt='%y/%m/%d %H:%M:%S')

    def get_message(self, prefix, msg = None):
        message_log = ""
        if msg is None :
            message_log = prefix
        else :
            message_log = f"[{prefix}]: {msg}"            

        return message_log

    def error(self, prefix, msg = None):
        logging.error(self.get_message(prefix, msg))

    def warn(self, prefix, msg = None):
        logging.warn(self.get_message(prefix, msg))

    def info(self, prefix, msg = None):
        logging.info(self.get_message(prefix, msg))