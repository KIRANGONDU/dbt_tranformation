# ============================================================================
# WEBHOOK DATA EXTRACTION GUIDE
# ============================================================================
# How to load data from webhooks/APIs into dbt pipelines
# ============================================================================

## OVERVIEW

Webhooks allow you to:
- Automatically trigger data extractions when events occur
- Stream real-time events to a data warehouse
- Integrate with APIs without manual intervention
- Load data into dbt for transformation

---

## ARCHITECTURE OPTIONS

### Option 1: Webhook → CSV → dbt seed

```
Event Triggers
    ↓
Webhook Receiver (Python/Node.js)
    ↓
Save to CSV in data/ folder
    ↓
dbt seed (load CSV)
    ↓
dbt run (transform)
```

**Pros:**
- Simple to implement
- Version controlled CSVs
- Good for reference data

**Cons:**
- Not real-time
- Doesn't scale to high-volume events

---

### Option 2: Webhook → Database → dbt source

```
Event Triggers
    ↓
Webhook Receiver (Python/Node.js)
    ↓
Insert directly to Database (staging table)
    ↓
dbt source() references staging table
    ↓
dbt run (transform from database)
```

**Pros:**
- Real-time data loading
- Scalable to high volume
- Database-native, fast

**Cons:**
- Need webhook infrastructure
- More complex setup

---

### Option 3: Webhook → Data Lake → dbt external source

```
Event Triggers
    ↓
Webhook Receiver (Python/Node.js)
    ↓
Cloud Storage (S3, GCS, Azure Blob)
    ↓
dbt external table (reads from cloud storage)
    ↓
dbt run (transform from external)
```

**Pros:**
- Scales to massive data
- Cloud-native, cost-effective
- Good data governance

**Cons:**
- Cloud setup required
- Latency from storage reads

---

## IMPLEMENTATION: OPTION 1 (Webhook → CSV)

### Step 1: Create Flask Webhook Receiver

**File: webhook_receiver.py**

```python
from flask import Flask, request
import json
import csv
from datetime import datetime
from pathlib import Path

app = Flask(__name__)

# Path to save CSVs
DATA_DIR = Path('data')
DATA_DIR.mkdir(exist_ok=True)

@app.route('/webhook/customers', methods=['POST'])
def receive_customer_webhook():
    """
    Receives customer data from webhook
    Expected JSON:
    {
        "events": [
            {"customer_id": 1, "name": "John", "email": "john@example.com"},
            ...
        ]
    }
    """
    try:
        data = request.get_json()
        events = data.get('events', [])
        
        # Append to CSV (creates if doesn't exist)
        csv_path = DATA_DIR / 'customers_webhook.csv'
        
        with open(csv_path, 'a', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['customer_id', 'name', 'email', 'received_at'])
            
            # Write header if file is empty
            f.seek(0, 2)  # Go to end
            if f.tell() == 0:
                writer.writeheader()
            
            # Write events
            for event in events:
                event['received_at'] = datetime.now().isoformat()
                writer.writerow(event)
        
        return {'status': 'success', 'count': len(events)}, 200
    
    except Exception as e:
        return {'status': 'error', 'message': str(e)}, 500


@app.route('/webhook/orders', methods=['POST'])
def receive_order_webhook():
    """
    Receives order events from webhook
    """
    try:
        data = request.get_json()
        events = data.get('events', [])
        
        csv_path = DATA_DIR / 'orders_webhook.csv'
        
        with open(csv_path, 'a', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=['order_id', 'customer_id', 'order_date', 'amount', 'status', 'received_at'])
            
            if f.tell() == 0:
                writer.writeheader()
            
            for event in events:
                event['received_at'] = datetime.now().isoformat()
                writer.writerow(event)
        
        return {'status': 'success', 'count': len(events)}, 200
    
    except Exception as e:
        return {'status': 'error', 'message': str(e)}, 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)
```

**Run webhook receiver:**
```bash
pip install flask
python webhook_receiver.py
# Server listens on http://localhost:5000
```

---

### Step 2: Create dbt Model to Load Webhook Data

**File: models/staging/stg_webhooks_customers.sql**

```sql
{{
  config(
    materialized = 'view',
    tags = ['webhook', 'staging']
  )
}}

-- Load data received via webhook
with webhook_data as (
  select
    customer_id,
    name as customer_name,
    lower(email) as email,
    current_date as signup_date,  -- Webhook doesn't provide, use today
    'UNKNOWN' as country,         -- Webhook doesn't provide
    md5(cast(customer_id as string) || email) as dbt_hashed_id,
    cast(received_at as timestamp) as loaded_at
  from {{ source('webhook', 'customers') }}
    -- Assumes webhook data is in a table in the database
    -- Or you can use: read_csv('data/customers_webhook.csv')
)

select * from webhook_data
where customer_id is not null
order by customer_id
```

---

### Step 3: Send Data to Webhook

**File: send_webhook_test.py**

```python
import requests
import json

def send_customer_webhook():
    """
    Simulates external service sending customer data to webhook
    """
    url = 'http://localhost:5000/webhook/customers'
    
    payload = {
        'events': [
            {
                'customer_id': '101',
                'name': 'Alice Anderson',
                'email': 'alice@example.com'
            },
            {
                'customer_id': '102',
                'name': 'Bob Brooks',
                'email': 'bob@example.com'
            }
        ]
    }
    
    response = requests.post(url, json=payload)
    print(response.json())

def send_order_webhook():
    """
    Simulates external service sending order data to webhook
    """
    url = 'http://localhost:5000/webhook/orders'
    
    payload = {
        'events': [
            {
                'order_id': '1001',
                'customer_id': '101',
                'order_date': '2024-11-20',
                'amount': '250.50',
                'status': 'completed'
            },
            {
                'order_id': '1002',
                'customer_id': '102',
                'order_date': '2024-11-20',
                'amount': '175.00',
                'status': 'pending'
            }
        ]
    }
    
    response = requests.post(url, json=payload)
    print(response.json())

if __name__ == '__main__':
    print("Sending customer data...")
    send_customer_webhook()
    
    print("\nSending order data...")
    send_order_webhook()
```

**Run to send test data:**
```bash
pip install requests
python send_webhook_test.py
```

---

### Step 4: Check CSV Files

After webhook runs, data appears in:
- `data/customers_webhook.csv`
- `data/orders_webhook.csv`

```csv
customer_id,name,email,received_at
101,Alice Anderson,alice@example.com,2024-11-20T14:30:22.123456
102,Bob Brooks,bob@example.com,2024-11-20T14:30:22.456789
```

---

### Step 5: Load into dbt

```bash
# Load CSV as seeds
dbt seed

# Run transformations
dbt run

# Test data quality
dbt test
```

---

## IMPLEMENTATION: OPTION 2 (Webhook → Database)

For high-volume, real-time data:

### Step 1: Create Webhook → Database Receiver

**File: webhook_to_database.py**

```python
from flask import Flask, request
import psycopg2  # PostgreSQL driver
from datetime import datetime

app = Flask(__name__)

# Database config
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'analytics',
    'user': 'postgres',
    'password': 'password'
}

def insert_to_database(table_name, data):
    """Insert event data directly to database"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        
        for event in data:
            # Dynamically build INSERT statement
            cols = list(event.keys()) + ['received_at']
            vals = list(event.values()) + [datetime.now()]
            
            placeholders = ','.join(['%s'] * len(cols))
            sql = f"INSERT INTO {table_name} ({','.join(cols)}) VALUES ({placeholders})"
            
            cur.execute(sql, vals)
        
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Database error: {e}")
        return False

@app.route('/webhook/customers', methods=['POST'])
def receive_customer_db():
    data = request.get_json()
    events = data.get('events', [])
    
    if insert_to_database('raw_customers_webhook', events):
        return {'status': 'success', 'count': len(events)}, 200
    else:
        return {'status': 'error'}, 500

@app.route('/webhook/orders', methods=['POST'])
def receive_order_db():
    data = request.get_json()
    events = data.get('events', [])
    
    if insert_to_database('raw_orders_webhook', events):
        return {'status': 'success', 'count': len(events)}, 200
    else:
        return {'status': 'error'}, 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)
```

### Step 2: Define Sources in dbt

**File: models/_sources.yml (add to existing file)**

```yaml
sources:
  - name: webhook_data
    database: analytics
    description: Data received from webhooks
    
    tables:
      - name: raw_customers_webhook
        description: Customers received via webhook
        columns:
          - name: customer_id
            tests:
              - not_null
          - name: name
          - name: email
          - name: received_at
      
      - name: raw_orders_webhook
        description: Orders received via webhook
        columns:
          - name: order_id
            tests:
              - not_null
          - name: customer_id
          - name: order_date
          - name: amount
          - name: status
          - name: received_at
```

### Step 3: Create Incremental Model

**File: models/staging/stg_webhook_orders_incremental.sql**

```sql
{{
  config(
    materialized = 'incremental',
    unique_key = 'order_id',
    tags = ['webhook', 'incremental']
  )
}}

select
  order_id,
  customer_id,
  cast(order_date as date) as order_date,
  cast(amount as numeric(10,2)) as amount,
  lower(status) as status,
  received_at
from {{ source('webhook_data', 'raw_orders_webhook') }}

{% if is_incremental() %}
  -- Only process new records (since last run)
  where received_at > (select max(received_at) from {{ this }})
{% endif %}

order by received_at desc
```

### Step 4: Run dbt with incremental updates

```bash
# First run: loads all history
dbt run --models stg_webhook_orders_incremental

# Subsequent runs: only new records
dbt run --models stg_webhook_orders_incremental
```

---

## WEBHOOK AUTHENTICATION & SECURITY

### Add Secret Token Verification

```python
import hmac
import hashlib

SECRET_TOKEN = "your-secret-webhook-key"

@app.route('/webhook/customers', methods=['POST'])
def receive_customer_webhook():
    # Verify webhook signature
    signature = request.headers.get('X-Webhook-Signature')
    body = request.get_data()
    
    expected_signature = hmac.new(
        SECRET_TOKEN.encode(),
        body,
        hashlib.sha256
    ).hexdigest()
    
    if signature != expected_signature:
        return {'status': 'unauthorized'}, 401
    
    # Process webhook...
```

---

## BEST PRACTICES FOR WEBHOOK DATA

### 1. **Idempotency**
Webhook may be sent multiple times. Handle duplicates:

```sql
-- In dbt model with unique_key
{{ config(unique_key = 'order_id') }}

select distinct
  order_id,
  customer_id,
  amount
from {{ source('webhook_data', 'raw_orders') }}
```

### 2. **Late Arriving Facts**
Handle data arriving out of order:

```sql
-- Add arrival timestamp to distinguish late events
select * from {{ source('webhook_data', 'orders') }}
where order_date >= current_date - 3  -- Only recent orders
order by received_at
```

### 3. **Audit Trail**
Always store when data arrived:

```sql
select
  order_id,
  received_at as event_timestamp,
  current_timestamp as loaded_at  -- When we processed it
from {{ source('webhook_data', 'orders') }}
```

### 4. **Schema Validation**
Validate incoming data before processing:

```python
from jsonschema import validate, ValidationError

WEBHOOK_SCHEMA = {
    'type': 'object',
    'properties': {
        'events': {
            'type': 'array',
            'items': {
                'type': 'object',
                'properties': {
                    'order_id': {'type': 'integer'},
                    'amount': {'type': 'number'},
                    'status': {'enum': ['completed', 'pending', 'cancelled']}
                },
                'required': ['order_id', 'amount']
            }
        }
    }
}

@app.route('/webhook/orders', methods=['POST'])
def receive_order_webhook():
    try:
        validate(instance=request.get_json(), schema=WEBHOOK_SCHEMA)
    except ValidationError as e:
        return {'error': str(e)}, 400
```

---

## EXAMPLE: REAL-TIME CUSTOMER EVENT TRACKING

### Scenario: Track customer logins via webhook

**Webhook sender (external app):**
```python
import requests

def log_customer_login(customer_id, login_time):
    requests.post('http://your-webhook-url.com/webhook/login', json={
        'events': [{
            'customer_id': customer_id,
            'login_time': login_time,
            'source': 'mobile_app'
        }]
    })
```

**Webhook receiver:**
```python
# Saves to: data/customer_logins_webhook.csv
```

**dbt model:**
```sql
-- models/staging/stg_customer_logins.sql
select
  customer_id,
  cast(login_time as timestamp) as login_time,
  source,
  current_date as login_date
from {{ source('webhook', 'customer_logins') }}
```

**Reporting query:**
```sql
select
  login_date,
  count(distinct customer_id) as daily_active_users,
  count(*) as total_logins,
  count(*) / count(distinct customer_id) as logins_per_user
from {{ ref('stg_customer_logins') }}
group by login_date
order by login_date desc
```

**Output (for dashboards):**
```
login_date  | daily_active_users | total_logins | logins_per_user
2024-11-20  | 1,245              | 3,421        | 2.75
2024-11-19  | 1,189              | 3,156        | 2.65
2024-11-18  | 1,412              | 3,890        | 2.75
```

---

## SUMMARY: WEBHOOK + DBT WORKFLOW

```
External Apps/Services
       ↓
Send Events via POST
       ↓
Webhook Endpoint (Flask)
       ↓
Save to CSV or Database
       ↓
dbt source() + {{ source() }}
       ↓
dbt staging models
       ↓
dbt marts (tables)
       ↓
Analytics & Reports
```

**Benefits:**
✓ Real-time data loading
✓ Automated transformations
✓ Data quality tests
✓ Complete lineage
✓ Version controlled
✓ Scalable
