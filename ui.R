library(rjson)
library(jsonlite)


#Add Google Analytics to the Shiny app must be done
# tags$head(includeScript("google-analytics.js"))


shinyUI(fluidPage(
#     include google analytics source http://shiny.rstudio.com/articles/google-analytics.html
#     tags$head(includeScript("google-analytics.js")),    

    # Application title
    titlePanel("Tweets location: Extract all the tweets made in France and some neigbouring countries"),
    sidebarPanel(
        textInput('TwitterQuery', "Text to be searched (#, @ included): ", "fibre"),
        numericInput('n_Tweets', 'Number of tweets to retrieve: ', 101, min = 1, max = 1500, step = 1) #labeled n_Tweets
    ),
    
    mainPanel(
        tabsetPanel(
            tabPanel("Map of the tweets", htmlOutput("sentiment")),
            tabPanel("Tweets", dataTableOutput("TwitterQuery"))
        )
    )

)
)