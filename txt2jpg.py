from PIL import Image

def txt_to_jpg(txt_filepath, jpg_filepath, width, height):
    """
    Chuyển đổi tệp văn bản chứa giá trị pixel hex (một pixel mỗi dòng)
    thành hình ảnh JPG thang độ xám.

    Args:
        txt_filepath (str): Đường dẫn đến tệp văn bản đầu vào.
        jpg_filepath (str): Đường dẫn để lưu tệp JPG đầu ra.
        width (int): Chiều rộng của hình ảnh.
        height (int): Chiều cao của hình ảnh.
    """
    pixel_values = []
    try:
        with open(txt_filepath, 'r') as f:
            for line in f:
                try:
                    # Loại bỏ khoảng trắng và chuyển đổi hex sang int
                    pixel_val = int(line.strip(), 16)
                    # Đảm bảo giá trị pixel nằm trong khoảng 0-255
                    pixel_values.append(max(0, min(pixel_val, 255)))
                except ValueError:
                    print(f"Cảnh báo: Bỏ qua dòng không hợp lệ hoặc không phải hex: {line.strip()}")
                    # Bạn có thể quyết định thêm một giá trị mặc định ở đây nếu cần, ví dụ: 0
                    # pixel_values.append(0) 
                    pass # Bỏ qua dòng lỗi và tiếp tục

        if len(pixel_values) != width * height:
            print(f"Cảnh báo: Số lượng pixel đọc được ({len(pixel_values)}) "
                  f"không khớp với kích thước hình ảnh dự kiến ({width*height}).")
            # Cắt bớt hoặc đệm nếu cần, hoặc báo lỗi nghiêm trọng hơn
            # Ví dụ: chỉ lấy đủ pixel cần thiết
            pixel_values = pixel_values[:width*height]
            # Hoặc nếu thiếu, đệm bằng màu đen (0)
            while len(pixel_values) < width * height:
                pixel_values.append(0)


        # Tạo hình ảnh thang độ xám mới
        # 'L' mode là cho hình ảnh thang độ xám (8-bit pixels, black and white)
        img = Image.new('L', (width, height))
        img.putdata(pixel_values)
        img.save(jpg_filepath)
        print(f"Hình ảnh đã được lưu thành công tại: {jpg_filepath}")

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp văn bản đầu vào: {txt_filepath}")
    except Exception as e:
        print(f"Đã xảy ra lỗi: {e}")

if __name__ == '__main__':
    # --- Cấu hình ---
    input_txt_file = "C:\\Users\\Administrator\\Desktop\\De_Tai_Median_Filter_Mon_HDL\\removed_noisyimg.txt"
    output_jpg_file = "C:\\Users\\Administrator\\Desktop\\De_Tai_Median_Filter_Mon_HDL\\removed_noisyimg.jpg"
    image_width = 430  # Chiều rộng hình ảnh từ Verilog
    image_height = 554 # Chiều cao hình ảnh từ Verilog
    # ------------------

    txt_to_jpg(input_txt_file, output_jpg_file, image_width, image_height)

    # Ví dụ khác nếu bạn có file gốc (noisy)
    # input_noisy_txt_file = "C:\\Users\\Administrator\\Desktop\\De_Tai_Median_Filter_Mon_HDL\\noisyimg.txt"
    # output_noisy_jpg_file = "C:\\Users\\Administrator\\Desktop\\De_Tai_Median_Filter_Mon_HDL\\noisyimg.jpg"
    # txt_to_jpg(input_noisy_txt_file, output_noisy_jpg_file, image_width, image_height)