FROM python 

RUN touch /toto_rm.txt
RUN touch /toto.txt

ENV tutu toto

RUN rm -f toto_rm.txt