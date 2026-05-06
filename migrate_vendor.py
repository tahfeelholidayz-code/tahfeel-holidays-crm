"""
One-time migration script to add vendor tables and columns
Run this once to update the database schema
"""
from app import app, db
from sqlalchemy import text

def migrate_vendor_system():
    """Add vendor tables and columns to existing database"""
    with app.app_context():
        try:
            # Check if vendor table exists
            result = db.session.execute(text("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_name = 'vendor'
                );
            """))
            vendor_table_exists = result.scalar()
            
            if not vendor_table_exists:
                print("Creating vendor table...")
                db.session.execute(text("""
                    CREATE TABLE vendor (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        company VARCHAR(100),
                        phone VARCHAR(20),
                        email VARCHAR(100),
                        address VARCHAR(200),
                        service_type VARCHAR(100),
                        bank_name VARCHAR(100),
                        account_number VARCHAR(50),
                        iban VARCHAR(50),
                        contact_person VARCHAR(100),
                        notes TEXT,
                        active BOOLEAN DEFAULT TRUE,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );
                """))
                print("✓ Vendor table created")
            else:
                print("✓ Vendor table already exists")
            
            # Check if vendor_payment table exists
            result = db.session.execute(text("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_name = 'vendor_payment'
                );
            """))
            vendor_payment_exists = result.scalar()
            
            if not vendor_payment_exists:
                print("Creating vendor_payment table...")
                db.session.execute(text("""
                    CREATE TABLE vendor_payment (
                        id SERIAL PRIMARY KEY,
                        job_id INTEGER NOT NULL REFERENCES job(id),
                        vendor_id INTEGER NOT NULL REFERENCES vendor(id),
                        amount_due FLOAT DEFAULT 0,
                        amount_paid FLOAT DEFAULT 0,
                        payment_status VARCHAR(20) DEFAULT 'Pending',
                        payment_date DATE,
                        due_date DATE,
                        notes TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );
                """))
                print("✓ Vendor_payment table created")
            else:
                print("✓ Vendor_payment table already exists")
            
            # Check if job.vendor_id column exists
            result = db.session.execute(text("""
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'job' AND column_name = 'vendor_id'
                );
            """))
            vendor_id_exists = result.scalar()
            
            if not vendor_id_exists:
                print("Adding vendor_id column to job table...")
                db.session.execute(text("""
                    ALTER TABLE job ADD COLUMN vendor_id INTEGER REFERENCES vendor(id);
                """))
                print("✓ vendor_id column added")
            else:
                print("✓ vendor_id column already exists")
            
            # Check if job.vendor_amount column exists
            result = db.session.execute(text("""
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'job' AND column_name = 'vendor_amount'
                );
            """))
            vendor_amount_exists = result.scalar()
            
            if not vendor_amount_exists:
                print("Adding vendor_amount column to job table...")
                db.session.execute(text("""
                    ALTER TABLE job ADD COLUMN vendor_amount FLOAT DEFAULT 0;
                """))
                print("✓ vendor_amount column added")
            else:
                print("✓ vendor_amount column already exists")
            
            # Check if job.vendor_paid column exists
            result = db.session.execute(text("""
                SELECT EXISTS (
                    SELECT FROM information_schema.columns 
                    WHERE table_name = 'job' AND column_name = 'vendor_paid'
                );
            """))
            vendor_paid_exists = result.scalar()
            
            if not vendor_paid_exists:
                print("Adding vendor_paid column to job table...")
                db.session.execute(text("""
                    ALTER TABLE job ADD COLUMN vendor_paid FLOAT DEFAULT 0;
                """))
                print("✓ vendor_paid column added")
            else:
                print("✓ vendor_paid column already exists")
            
            db.session.commit()
            print("\n✅ Vendor system migration completed successfully!")
            return "Migration completed successfully"
            
        except Exception as e:
            db.session.rollback()
            print(f"\n❌ Migration failed: {str(e)}")
            return f"Migration failed: {str(e)}"

if __name__ == '__main__':
    result = migrate_vendor_system()
    print(result)
