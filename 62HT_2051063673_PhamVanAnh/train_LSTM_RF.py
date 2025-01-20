import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import MinMaxScaler

# 1. Tiền xử lý dữ liệu
# Load dữ liệu
data = pd.read_csv('11zon_Data_hothuydien.csv')

# Chọn các cột liên quan
features = ['muc_nuoc_ho', 'luu_luong_den']
target = 'luu_luong_xa'

# Chuẩn hóa dữ liệu
scaler = MinMaxScaler()
data_scaled = scaler.fit_transform(data[features])

# Chia dữ liệu thành tập huấn luyện và tập kiểm tra
train_size = int(len(data) * 0.8)
train_data = data_scaled[:train_size]
test_data = data_scaled[train_size:]


# 2. Chuẩn bị dữ liệu cho LSTM
def create_dataset(dataset, look_back=1):
    X, y = [], []
    for i in range(len(dataset) - look_back - 1):
        X.append(dataset[i:(i + look_back), :])
        y.append(dataset[i + look_back, 1])  # Chỉ lấy 'luu_luong_xa' làm mục tiêu
    return np.array(X), np.array(y)

look_back = 3  # Số lượng thời gian trước đó để xem xét
X_train, y_train = create_dataset(train_data, look_back)
X_test, y_test = create_dataset(test_data, look_back)

# Reshape dữ liệu để phù hợp với yêu cầu của LSTM
X_train = np.reshape(X_train, (X_train.shape[0], X_train.shape[1], X_train.shape[2]))
X_test = np.reshape(X_test, (X_test.shape[0], X_test.shape[1], X_test.shape[2]))

def augment_data(X):
    noise = np.random.normal(0, 0.01, X.shape)  # Thêm nhiễu với độ lệch chuẩn là 0.01
    return X + noise

X_train_augmented = augment_data(X_train)

# 3. Xây dựng và huấn luyện mô hình LSTM
def create_model(learning_rate):
    model = Sequential()
    model.add(LSTM(50, return_sequences=True, input_shape=(X_train.shape[1], X_train.shape[2])))
    model.add(Dropout(0.2))
    model.add(LSTM(50))
    model.add(Dropout(0.2))
    model.add(Dense(1))
    model.compile(optimizer='adam', loss='mean_squared_error', metrics=['mae'])
    return model

# Thay đổi learning_rate và batch_size
learning_rate = 0.0001  # Bạn có thể thử với 0.01, 0.0001
batch_size = 32  # Bạn có thể thử với 16, 64

model = create_model(learning_rate)
model.fit(X_train_augmented, y_train, epochs=100, batch_size=32, validation_data=(X_test, y_test))

# Trích xuất các đặc trưng từ LSTM (đầu ra của lớp LSTM cuối cùng)
lstm_features_train = model.predict(X_train)
lstm_features_test = model.predict(X_test)

# 4. Huấn luyện Random Forest với các đặc trưng từ LSTM
rf = RandomForestRegressor(n_estimators=100, random_state=42)
rf.fit(lstm_features_train, y_train)

# Dự đoán với Random Forest
y_pred_rf = rf.predict(lstm_features_test)

# 5. Đánh giá mô hình
mse_rf = mean_squared_error(y_test, y_pred_rf)
rmse_rf = np.sqrt(mse_rf)
mae_rf = mean_absolute_error(y_test, y_pred_rf)
r2_rf = r2_score(y_test, y_pred_rf)

model.save('lstm_model.h5')
import pickle


# Lưu mô hình
with open('rf_model.pkl', 'wb') as file:
    pickle.dump(rf, file)

print(f'R² (Random Forest): {r2_rf}')
print(f'MSE (Random Forest): {mse_rf}')
print(f'RMSE (Random Forest): {rmse_rf}')
print(f'MAE (Random Forest): {mae_rf}')

import matplotlib.pyplot as plt

plt.plot(y_test, label='Thực tế')
plt.plot(y_pred_rf, label='Dự đoán')
plt.xlabel('Thời gian')
plt.ylabel('Lưu lượng xả (m³/s)')
plt.title('So sánh lưu lượng xả thực tế và dự đoán')
plt.legend()
plt.show()