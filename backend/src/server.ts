import dotenv from 'dotenv';
import app from './app';

dotenv.config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Warehouse Receipt API Server is running on port ${PORT}`);
  console.log(`📑 Swagger Documentation available at http://localhost:${PORT}/swagger`);
});
