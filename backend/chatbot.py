# import streamlit as st

# from langchain_core.prompts import ChatPromptTemplate
# from langchain_core.output_parsers import StrOutputParser
# from langchain_community.llms import Ollama


# # Page title
# st.title("Food AI Chat")


# # Load local model (free)
# llm = Ollama(model="llama2")


# # Prompt template
# prompt = ChatPromptTemplate.from_messages(
#     [
#         ("system", "You are a helpful AI food assistant."),
#         ("human", "{question}")
#     ]
# )


# # Output parser
# output_parser = StrOutputParser()


# # Chain
# chain = prompt | llm | output_parser


# # User input
# user_input = st.text_input("Ask about food...")


# # Run chatbot
# if user_input:
#     response = chain.invoke({"question": user_input})
#     st.write(response)