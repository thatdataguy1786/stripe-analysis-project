"""
Test Database Connection with Environment Variables
This script tests if:
1. .env file is loading correctly
2. Environment variables are accessible
3. Database connection works with the env variable
"""

import os
from dotenv import load_dotenv
import psycopg2

print("=" * 50)
print("🧪 TESTING DATABASE CONNECTION")
print("=" * 50)

# Step 1: Load environment variables
print("\n[Step 1] Loading .env file...")
load_dotenv()
print("✅ .env file loaded")

# Step 2: Check if password exists
print("\n[Step 2] Checking if DB_PASSWORD exists...")
password = os.getenv('DB_PASSWORD')

if password:
    print(f"✅ DB_PASSWORD found (length: {len(password)} characters)")
    # Show only first 2 characters for security
    print(f"   Password starts with: {password[:2]}***")
else:
    print("❌ DB_PASSWORD not found in environment variables!")
    print("   Make sure your .env file exists and contains:")
    print("   DB_PASSWORD=Postgres17!")
    exit(1)

# Step 3: Test database connection
print("\n[Step 3] Testing PostgreSQL connection...")
try:
    conn = psycopg2.connect(
        host="localhost",
        database="stripe_db",
        user="postgres",
        password=password
    )
    print("✅ Successfully connected to PostgreSQL!")
    
    # Test a simple query
    cur = conn.cursor()
    cur.execute("SELECT version();")
    version = cur.fetchone()
    print(f"   PostgreSQL version: {version[0][:50]}...")
    
    # Close connection
    cur.close()
    conn.close()
    print("✅ Connection closed successfully")
    
    print("\n" + "=" * 50)
    print("🎉 ALL TESTS PASSED!")
    print("=" * 50)
    print("\n✅ You can now safely update your main Python files")
    print("   with the environment variable approach.")
    
except psycopg2.OperationalError as e:
    print(f"❌ Connection failed: {e}")
    print("\n⚠️  Possible issues:")
    print("   1. PostgreSQL is not running")
    print("   2. Database 'stripe_db' doesn't exist")
    print("   3. Wrong username or password")
    print("   4. Wrong host or port")
    
except Exception as e:
    print(f"❌ Unexpected error: {e}")