import tkinter as tk
from tkinter import messagebox
import numpy as np
from tensorflow.keras.models import load_model
import pickle
import pandas as pd
from sklearn.preprocessing import MinMaxScaler

# Dữ liệu bảng mực nước hồ và thể tích (triệu m³)
volume_to_water = {
    427: 0,
    430: 0.77,
    435: 7.13,
    440: 21.75,
    445: 49.47,
    450: 89.30,
    455: 138.23,
    460: 196.24,
    465: 264.29,
    470: 344.25,
    475: 437.34,
    480: 550.11,
    485: 694.31,
    490: 879.43,
    495: 1114.15,
    500: 1406.40,
}

# Tải mô hình đã lưu
lstm_model = load_model('lstm_model.h5')
with open('rf_model.pkl', 'rb') as file:
    rf_model = pickle.load(file)

# Chuẩn bị scaler để chuẩn hóa dữ liệu
data = pd.read_csv('11zon_Data_hothuydien.csv')
features = ['muc_nuoc_ho', 'luu_luong_den']
scaler = MinMaxScaler()
scaler.fit(data[features])

# Hàm nội suy thể tích nước thành mực nước (triệu m³ -> m)
def volume_to_water_level(volume):
    return np.interp(volume, list(volume_to_water.values()), list(volume_to_water.keys()))

# Hàm nội suy mực nước thành thể tích nước (m -> triệu m³)
def water_level_to_volume(water_level):
    return np.interp(water_level, list(volume_to_water.keys()), list(volume_to_water.values()))

# Hàm dự đoán lưu lượng xả và tính toán mực nước
def predict_discharge():
    try:
        # Lấy dữ liệu từ giao diện
        water_level = float(entry_water_level.get().strip().replace(',', '.'))  # Mực nước ban đầu (m)
        inflow = float(entry_inflow.get().strip().replace(',', '.'))  # Lưu lượng đến (m³/s)
        time_period = 24 * 3600  # 24 giờ tính bằng giây

        # Chuyển đổi mực nước ban đầu sang thể tích ban đầu (triệu m³)
        V1 = water_level_to_volume(water_level)

        # Chuẩn bị dữ liệu đầu vào cho mô hình
        input_data = np.array([[water_level, inflow]])
        input_data_scaled = scaler.transform(input_data.reshape(-1, 2))

        # Tạo chuỗi đầu vào cho LSTM
        input_sequence = np.array([input_data_scaled]).reshape(1, 1, 2)

        # Dự đoán lưu lượng xả bằng mô hình
        lstm_features = lstm_model.predict(input_sequence)
        predicted_discharge_scaled = rf_model.predict(lstm_features)

        # Chuyển ngược lưu lượng xả từ scaled về giá trị thực (m³/s)
        predicted_discharge = scaler.inverse_transform(
            np.hstack((np.zeros((1, 1)), predicted_discharge_scaled.reshape(-1, 1)))
        )[:, 1][0]

        # Tính toán thể tích mới (triệu m³)
        V2 = V1 + ((inflow - predicted_discharge) / 2) * time_period / 1_000_000  # Chuyển m³ -> triệu m³

        # Nội suy thể tích mới thành mực nước mới (m)
        new_water_level = volume_to_water_level(V2)

        # Hiển thị kết quả và cập nhật giao diện
        entry_water_level.delete(0, tk.END)
        entry_water_level.insert(0, f"{new_water_level:.2f}")
        result = f"Lưu lượng xả dự đoán: {predicted_discharge:.2f} m³/s\nMực nước hồ mới: {new_water_level:.2f} m"
        messagebox.showinfo("Kết quả dự đoán", result)

        # Xuất kết quả ra file CSV
        with open('du_lieu_du_doan.csv', 'a') as f:
            f.write(f"{inflow:.2f},{water_level:.2f},{predicted_discharge:.2f}\n")

    except ValueError as ve:
        messagebox.showerror("Lỗi", f"Giá trị nhập không hợp lệ: {ve}")
    except Exception as e:
        messagebox.showerror("Lỗi", f"Đã xảy ra lỗi: {e}")

# Tạo giao diện ứng dụng
window = tk.Tk()
window.title("Dự đoán Lưu lượng Xả và Mực nước")
window.geometry("600x400")
window.resizable(False, False)
window.configure(bg="#f5f5f5")

# Nhãn tiêu đề
title_label = tk.Label(window, text="Ứng dụng Dự đoán Lưu lượng Xả và Mực nước", font=("Arial", 16, "bold"), bg="#f5f5f5", fg="#333333")
title_label.pack(pady=15)

# Mực nước hồ
water_level_label = tk.Label(window, text="Mực nước hồ hiện tại (m):", font=("Arial", 12), bg="#f5f5f5", fg="#333333")
water_level_label.pack(pady=5)
entry_water_level = tk.Entry(window, font=("Arial", 12), width=30)
entry_water_level.pack(pady=5)
entry_water_level.insert(0, "487.50")  # Mực nước ban đầu

# Lưu lượng đến
inflow_label = tk.Label(window, text="Lưu lượng đến hồ (m³/s):", font=("Arial", 12), bg="#f5f5f5", fg="#333333")
inflow_label.pack(pady=5)
entry_inflow = tk.Entry(window, font=("Arial", 12), width=30)
entry_inflow.pack(pady=5)

# Nút dự đoán
predict_button = tk.Button(window, text="Dự đoán", font=("Arial", 12, "bold"), bg="#007BFF", fg="white", width=20, command=predict_discharge)
predict_button.pack(pady=20)

# Nhãn ghi chú
note_label = tk.Label(window, text="Nhập giá trị lưu lượng đến và nhấn 'Dự đoán' để bắt đầu.", font=("Arial", 10), bg="#f5f5f5", fg="#555555")
note_label.pack(pady=10)

# Chạy ứng dụng
window.mainloop()
