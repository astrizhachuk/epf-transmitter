FROM squidfunk/mkdocs-material:latest

RUN pip install --no-cache-dir \
    mkdocs-macros-plugin \
    mkdocs-glightbox \
    mkdocs_puml \
    pygments-bsl

