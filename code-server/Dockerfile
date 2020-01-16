# Written by Stephen Reaves
# Create VSCode Server with Netsuite Upload extension pre-loaded

FROM codercom/code-server:v2

RUN sudo apt install -y nodejs \
  && code-server --host 0.0.0.0 --install-extension nsupload-org.netsuite-upload

ENTRYPOINT ["dumb-init", "code-server", "--host", "0.0.0.0"]
