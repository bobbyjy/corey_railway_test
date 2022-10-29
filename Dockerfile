FROM rocker/tidyverse:4

WORKDIR /app

RUN R -e "install.packages('jsonlite',dependencies=TRUE,repos='http://cran.rstudio.com/')"

RUN R -e "install.packages('RPostgres',dependencies=TRUE,repos='http://cran.rstudio.com/')"

COPY test.r

CMD ["R", "-f", "testing.r"]
