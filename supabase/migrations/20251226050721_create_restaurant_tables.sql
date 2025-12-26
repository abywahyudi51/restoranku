/*
  # Create Restaurant QR Code System Tables

  ## Overview
  This migration sets up the complete database schema for a QR code-based restaurant ordering system.

  ## New Tables
  
  ### `menu_items`
  Stores all menu items available in the restaurant
  - `id` (uuid, primary key) - Unique identifier
  - `name` (text) - Name of the dish/drink
  - `description` (text) - Description of the item
  - `price` (numeric) - Price of the item
  - `category` (text) - Category: 'Makanan', 'Minuman', or 'Dessert'
  - `image_url` (text) - URL to item image
  - `available` (boolean) - Whether item is currently available
  - `created_at` (timestamptz) - Creation timestamp

  ### `orders`
  Stores customer orders
  - `id` (uuid, primary key) - Unique order identifier
  - `customer_name` (text) - Name of the customer
  - `table_number` (text) - Table number
  - `status` (text) - Order status: 'pending', 'preparing', 'ready', 'completed'
  - `total_amount` (numeric) - Total order amount
  - `notes` (text) - Special requests/notes
  - `created_at` (timestamptz) - Order creation time

  ### `order_items`
  Links orders with menu items (order details)
  - `id` (uuid, primary key) - Unique identifier
  - `order_id` (uuid, foreign key) - References orders table
  - `menu_item_id` (uuid, foreign key) - References menu_items table
  - `quantity` (integer) - Quantity ordered
  - `price` (numeric) - Price at time of order
  - `item_name` (text) - Snapshot of item name

  ## Security
  - Enable RLS on all tables
  - Public read access for menu_items (customers need to see menu)
  - Public insert access for orders and order_items (customers can place orders)
  - Public read access for orders (for real-time updates)
  - Admin policies can be added later for management

  ## Indexes
  - Index on orders.created_at for efficient sorting
  - Index on orders.status for filtering
  - Index on menu_items.category for filtering
*/

-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text DEFAULT '',
  price numeric(10,2) NOT NULL,
  category text NOT NULL,
  image_url text DEFAULT '',
  available boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  table_number text NOT NULL,
  status text DEFAULT 'pending',
  total_amount numeric(10,2) NOT NULL,
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id uuid NOT NULL REFERENCES menu_items(id),
  quantity integer NOT NULL,
  price numeric(10,2) NOT NULL,
  item_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- Enable Row Level Security
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for menu_items
CREATE POLICY "Anyone can view available menu items"
  ON menu_items FOR SELECT
  USING (true);

CREATE POLICY "Anyone can view all menu items"
  ON menu_items FOR SELECT
  USING (true);

-- RLS Policies for orders
CREATE POLICY "Anyone can view orders"
  ON orders FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert orders"
  ON orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update orders"
  ON orders FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- RLS Policies for order_items
CREATE POLICY "Anyone can view order items"
  ON order_items FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert order items"
  ON order_items FOR INSERT
  WITH CHECK (true);

-- Insert sample menu items
INSERT INTO menu_items (name, description, price, category, image_url) VALUES
-- Makanan
('Nasi Goreng Special', 'Nasi goreng dengan telur, ayam, dan sayuran segar', 35000, 'Makanan', 'https://images.pexels.com/photos/1410235/pexels-photo-1410235.jpeg'),
('Mie Goreng', 'Mie goreng pedas dengan seafood', 32000, 'Makanan', 'https://images.pexels.com/photos/2862718/pexels-photo-2862718.jpeg'),
('Ayam Bakar', 'Ayam bakar bumbu kecap dengan lalapan', 40000, 'Makanan', 'https://images.pexels.com/photos/2338407/pexels-photo-2338407.jpeg'),
('Sate Ayam', 'Sate ayam 10 tusuk dengan bumbu kacang', 38000, 'Makanan', 'https://images.pexels.com/photos/3731134/pexels-photo-3731134.jpeg'),
('Gado-Gado', 'Sayuran segar dengan bumbu kacang', 28000, 'Makanan', 'https://images.pexels.com/photos/1640774/pexels-photo-1640774.jpeg'),
('Rendang', 'Rendang daging sapi dengan nasi putih', 45000, 'Makanan', 'https://images.pexels.com/photos/4869224/pexels-photo-4869224.jpeg'),

-- Minuman
('Es Teh Manis', 'Teh manis dingin segar', 8000, 'Minuman', 'https://images.pexels.com/photos/1638280/pexels-photo-1638280.jpeg'),
('Es Jeruk', 'Jus jeruk segar dengan es', 12000, 'Minuman', 'https://images.pexels.com/photos/1435740/pexels-photo-1435740.jpeg'),
('Kopi Hitam', 'Kopi hitam original', 15000, 'Minuman', 'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg'),
('Cappuccino', 'Kopi cappuccino dengan foam creamy', 22000, 'Minuman', 'https://images.pexels.com/photos/1251175/pexels-photo-1251175.jpeg'),
('Jus Alpukat', 'Jus alpukat segar dengan susu', 18000, 'Minuman', 'https://images.pexels.com/photos/5945750/pexels-photo-5945750.jpeg'),
('Thai Tea', 'Thai tea original dengan susu', 15000, 'Minuman', 'https://images.pexels.com/photos/4051391/pexels-photo-4051391.jpeg'),

-- Dessert
('Es Krim Vanilla', 'Es krim vanilla dengan topping', 20000, 'Dessert', 'https://images.pexels.com/photos/1362534/pexels-photo-1362534.jpeg'),
('Pisang Goreng', 'Pisang goreng crispy dengan meses', 15000, 'Dessert', 'https://images.pexels.com/photos/5966821/pexels-photo-5966821.jpeg'),
('Brownies Coklat', 'Brownies coklat lumer dengan ice cream', 25000, 'Dessert', 'https://images.pexels.com/photos/1721934/pexels-photo-1721934.jpeg'),
('Pudding', 'Pudding karamel lembut', 18000, 'Dessert', 'https://images.pexels.com/photos/5848427/pexels-photo-5848427.jpeg'),
('Es Campur', 'Es campur dengan buah dan jelly', 22000, 'Dessert', 'https://images.pexels.com/photos/12737636/pexels-photo-12737636.jpeg')
ON CONFLICT DO NOTHING;