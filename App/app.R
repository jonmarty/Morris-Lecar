#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)

#Define functions
M_ss = function(V, V_1, V_2) (1/2) * (1 + tanh((V - V_1) / V_2))
N_ss = function(V, V_3, V_4) (1/2) * (1 + tanh((V - V_3) / V_4))
T_N =  function(V, V_3, V_4, phi) 1 / (phi * cosh((V - V_3) / (2 * V_4)))

#Define differential equations
dV = function(I, g_L, V, V_L, g_Ca, V_Ca, g_K, N, V_K, C, V_1, V_2) (I - g_L * (V - V_L) - g_Ca * M_ss(V, V_1, V_2) * (V - V_Ca) - g_K * N * (V - V_K)) / C
dN = function(N, V, V_3, V_4, phi)  (N_ss(V, V_3, V_4) - N) / T_N(V, V_3, V_4, phi)

#Equations for the input of each channel
L = function(g_L, V, V_L) - g_L * (V - V_L)
Ca = function(g_Ca, V, V_Ca, V_1, V_2) - g_Ca * M_ss(V, V_1, V_2) * (V - V_Ca)
K = function(g_K, N, V, V_K) - g_K * N * (V - V_K)

run_model <- function(current, params){
  rows <- c()
  
  C = params$C
  V_1 = params$V_1
  V_2 = params$V_2
  V_3 = params$V_3
  V_4 = params$V_4
  phi = params$phi
  V_L = params$V_L
  V_Ca = params$V_Ca
  V_K = params$V_K
  g_Ca = params$g_Ca
  g_K = params$g_K
  g_L = params$g_L
  V = params$V
  N = params$N
  
  for(t in 1:length(current)){
    I <- current[t]
    
    #Update variables
    V = V + dV(I, g_L, V, V_L, g_Ca, V_Ca, g_K, N, V_K, C, V_1, V_2)
    N = N + dN(N, V, V_3, V_4, phi)
    
    #Update table
    row <- list()
    row$t <- t
    row$I <- I
    row$V <- V
    row$N <- N
    row$L <- L(g_L, V, V_L)
    row$Ca <- Ca(g_Ca, V, V_Ca, V_1, V_2)
    row$K <- K(g_K, N, V, V_K)
    row$N_ss <- N_ss(V, V_3, V_4)
    row$T_N <- T_N(V, V_3, V_4, phi)
    row <- data.table(row)
    
    rows <- c(rows, row)
  }
  
  output <- rbindlist(rows)
  names(output) <- c("t", "I", "V", "N", "L", "Ca", "K", "N_ss", "T_N")
  
  output
}

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Morris Lecar Neuron"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         numericInput("C", "Capacitance", 6.69810502993),
         numericInput("V_1", "Tuning Variable 1", 30),
         numericInput("V_2", "Tuning Variable 2", 15),
         numericInput("V_3", "Tuning Variable 3", 0),
         numericInput("V_4", "Tuning Variable 4", 30),
         numericInput("phi", "Reference Frequency", 0.025),
         numericInput("V_L", "Lithium Ion Channel Equilibrium Potential", -50),
         numericInput("V_Ca", "Calcium Ion Channel Equilibrium Potential", 100),
         numericInput("V_K", "Potassium Ion Channel Equilibrium Potential", -70),
         numericInput("g_L", "Lithium Conductance through Membrane", 0.5),
         numericInput("g_Ca", "Calcium Conductance through Membrane", 1.1),
         numericInput("g_K", "Potassium Conductance through Membrane", 2),
         numericInput("V", "Initial Membrane Potential", -52.14),
         numericInput("N", "Initial Recovery Variable", 0.02),
         numericInput("len_current", "Length of Input Stimulus", 1000),
         textInput("expr_current", "Current Expression (Use t as variable)", "t"),
         radioButtons("choices", "Variable to Plot", c(
           "I", "V", "N", "L", "Ca", "K", "N_ss", "T_N"
         )),
         submitButton("Run Model")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("currentPlot"),
         plotOutput("linePlot"),
         plotOutput("phasePortrait")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  current = c()
  
  #Plot the current
  output$currentPlot <- renderPlot({
    #Generate the current
    base_string = "unlist(lapply(1:REP1, function(t) {REP2}))"
    expr = gsub("REP1", as.character(input$len_current), base_string)
    expr = gsub("REP2", input$expr_current, expr)
    current = eval(parse(text=expr))
    
    #Plot the current
    plot(current, type='l', main = "Input Stimulus", xlab = "Time", ylab = "Current (A)")
  })
  
  #Plot the results
  output$linePlot <- renderPlot({
    #Generate the current
    base_string = "unlist(lapply(1:REP1, function(t) {REP2}))"
    expr = gsub("REP1", as.character(input$len_current), base_string)
    expr = gsub("REP2", input$expr_current, expr)
    current = eval(parse(text=expr))
    
    #Run the model
    data <- run_model(current, params = input)
    
    #Tried to use get() to simplify this, kept getting CHARSXP error
    base_string = "data$REP"
    expr = gsub("REP", input$choices, base_string)
    c = eval(parse(text=expr))
    
    #Plot values
    plot(c, type='l', main = "Chosen Variable", xlab = "Time", ylab = input$choices)
  })
  
  output$phasePortrait <- renderPlot({
    #Generate the current
    base_string = "unlist(lapply(1:REP1, function(t) {REP2}))"
    expr = gsub("REP1", as.character(input$len_current), base_string)
    expr = gsub("REP2", input$expr_current, expr)
    current = eval(parse(text=expr))
    
    #Run the model
    data <- run_model(current, params = input)
    
    print(data)
    
    #Plot phase portrait
    plot(data$N, data$V, type='l', main="Phase Portrait", xlab = "Recovery Variable(N)", ylab = "Membrane Potential (V)")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

