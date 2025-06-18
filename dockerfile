# Use AWS Lambda base image for Python

FROM public.ecr.aws/lambda/python:3.10

# Copy app code
COPY lambda_function.py .  
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Set the entry point for Lambda
CMD ["lambda_function.lambda_handler"]

