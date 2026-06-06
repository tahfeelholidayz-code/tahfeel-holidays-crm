"""
One-time cleanup: relink legacy manual visa entries from the dummy customer (#1)
to real Customer records.

Background: older "Add Visa" code attached every manual visa to customer_id = 1.
This script finds those jobs, creates (or reuses) a proper Customer from the visa's
stored name/phone/nationality/dob, and repoints job.customer_id to it.

SAFE:
  - Only touches jobs with job_type == 'Manual Visa Entry' AND customer_id == 1.
  - Reuses an existing customer when the phone already matches (no duplicates).
  - Idempotent: once a job is relinked it is no longer customer #1, so re-running
    this script does nothing further.
  - Never deletes customer #1 or any record.

USAGE (in the Railway shell):
  python migrate_visa_customers.py            # dry run - shows what WOULD change
  python migrate_visa_customers.py --commit   # actually apply the changes
"""

import sys
from app import app, db, Job, Customer


def run(commit: bool):
    targets = Job.query.filter_by(job_type='Manual Visa Entry', customer_id=1).all()
    print(f"Found {len(targets)} legacy manual visa entries on dummy customer #1.\n")

    created, reused, skipped = 0, 0, 0

    for job in targets:
        name = job.visa_customer_name
        phone = job.visa_customer_phone

        if not name and not phone:
            print(f"  [skip] Job {job.id}: no name or phone to build a customer from.")
            skipped += 1
            continue

        # Reuse a customer with the same phone, else create a new one
        customer = None
        if phone:
            customer = Customer.query.filter_by(phone=phone).first()

        if customer:
            action = f"reuse existing customer #{customer.id} ({customer.name})"
            reused += 1
        else:
            customer = Customer(
                name=name or 'Unknown',
                phone=phone,
                nationality=job.visa_nationality,
                date_of_birth=job.visa_dob,
                source='Visa Management',
                customer_type='Individual',
            )
            if commit:
                db.session.add(customer)
                db.session.flush()  # assign an id
            action = f"create new customer ({name})"
            created += 1

        print(f"  Job {job.id}  '{name}'  ->  {action}")
        if commit:
            job.customer_id = customer.id

    if commit:
        db.session.commit()
        print("\nCOMMITTED.")
    else:
        print("\nDRY RUN - nothing saved. Re-run with --commit to apply.")

    print(f"\nSummary: {created} created, {reused} reused, {skipped} skipped, "
          f"{len(targets)} total examined.")


if __name__ == '__main__':
    commit = '--commit' in sys.argv
    with app.app_context():
        run(commit)
