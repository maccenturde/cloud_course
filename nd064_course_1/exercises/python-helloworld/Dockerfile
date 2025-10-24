FROM python:3.12-slim

# Prevent Python from buffering stdout/stderr (helps with logging)
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Expose the port the app runs on
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
