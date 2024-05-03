import { Controller } from "@hotwired/stimulus"
import Dexie from 'dexie';

export default class extends Controller {
    connect() {
        this.db = new Dexie("MyDatabase");

        this.db.version(1).stores({
            items: '++id, name, description, status'
        });

        this.db.open().catch((error) => {
            console.error(`Failed to open db: ${error.stack}`);
        });

        console.log("Database setup completed.");
    }

    // Example method to add items to the database
    addItem(name, description) {
        return this.db.items.add({ name, description, status: 'pending' });
    }

    // Example method to fetch all items
    fetchItems() {
        return this.db.items.toArray();
    }
}
