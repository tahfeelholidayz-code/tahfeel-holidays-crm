"""
Database initialization script for Tahfeel Holidays CRM
Run this once to create tables and default admin user
"""
from app import app, db, User
from werkzeug.security import generate_password_hash

def init_database():
    with app.app_context():
        print("Creating database tables...")
        db.create_all()
        print("✓ Tables created")
        
        # Check if admin exists
        admin = User.query.filter_by(email='admin@tahfeel.ae').first()
        if not admin:
            print("Creating default admin user...")
            admin = User(
                name='Admin',
                email='admin@tahfeel.ae',
                password=generate_password_hash('tahfeel2026'),
                role='admin',
                active=True
            )
            db.session.add(admin)
            db.session.commit()
            print("✓ Admin user created")
            print("\nLogin credentials:")
            print("Email: admin@tahfeel.ae")
            print("Password: tahfeel2026")
        else:
            print("Admin user already exists")
            
        print("\n✓ Database initialization complete!")

if __name__ == '__main__':
    init_database()
