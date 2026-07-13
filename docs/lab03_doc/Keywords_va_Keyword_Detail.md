# 1. Màn hình Keywords

Tài liệu yêu cầu màn hình này hiển thị bốn nhóm thông tin: **Most frequent keywords**, **Trending keywords**, **Keyword frequency statistics** và **Keyword trend charts**. Khi chọn một keyword, người dùng được chuyển tới màn hình Keyword Detail.

## Most frequent keywords

Là những từ khóa xuất hiện trong **nhiều publication nhất** thuộc chủ đề hiện tại.

Ví dụ trong 100 bài về Artificial Intelligence:

| Keyword | Số publication |
|---|---:|
| Machine Learning | 65 |
| Deep Learning | 48 |
| Neural Networks | 37 |
| Computer Vision | 25 |

Danh sách sẽ được sắp xếp từ số lượng cao xuống thấp.

Nên tính theo **số publication chứa keyword**, không nên đếm số lần một từ lặp lại trong cùng một bài.

## Trending keywords

Là những từ khóa có xu hướng **tăng nhanh trong các năm gần đây**.

Nó khác với “most frequent”:

- **Most frequent:** tổng số publication cao nhất trong toàn bộ khoảng thời gian.
- **Trending:** số publication đang tăng mạnh gần đây.

Ví dụ:

| Keyword | 2023 | 2024 | 2025 | Nhận xét |
|---|---:|---:|---:|---|
| Machine Learning | 200 | 210 | 220 | Phổ biến nhưng tăng chậm |
| Generative AI | 20 | 80 | 190 | Đang tăng rất nhanh |

Trong trường hợp này:

- `Machine Learning` có thể là keyword phổ biến nhất.
- `Generative AI` có thể là keyword trending nhất.

Tài liệu không quy định công thức cụ thể, nên nhóm có thể tự chọn cách tính, chẳng hạn:

```text
Growth = publications năm mới nhất - publications năm trước
```

Hoặc:

```text
Growth rate =
(publications năm mới nhất - publications năm trước)
÷ publications năm trước × 100%
```

## Keyword frequency statistics

Đây là các số liệu thống kê của từng keyword, ví dụ:

- Số publication chứa keyword.
- Tỷ lệ publication chứa keyword trên tổng số publication.
- Số publication theo từng năm.
- Mức tăng hoặc giảm so với năm trước.
- Năm keyword hoạt động mạnh nhất.

Ví dụ:

```text
Keyword: Deep Learning
Publication count: 48
Percentage: 48%
Most active year: 2025
Growth from 2024: +20%
```

## Keyword trend charts

Là biểu đồ cho biết số lượng publication của keyword thay đổi theo thời gian.

Ví dụ:

```text
Deep Learning

2021: 10 publications
2022: 18 publications
2023: 27 publications
2024: 35 publications
2025: 48 publications
```

Có thể biểu diễn bằng:

- Line chart để thể hiện xu hướng.
- Bar chart để so sánh giữa các năm.

# 2. Màn hình Keyword Detail

Khi người dùng nhấn vào một keyword, ứng dụng phải mở màn hình chi tiết và phân tích dữ liệu liên quan đến keyword đó. Tài liệu yêu cầu:

- Publication trends over time.
- Related journals.
- Related publications.
- Top contributing authors.
- Author publication counts.
- Author ranking list hoặc chart.

Các tác giả phải được xếp giảm dần theo số publication liên quan đến keyword được chọn.

Ví dụ người dùng chọn keyword **“Deep Learning”**.

## Publication trends over time

Hiển thị số bài có keyword `Deep Learning` theo từng năm:

| Năm | Publications |
|---|---:|
| 2021 | 10 |
| 2022 | 18 |
| 2023 | 27 |
| 2024 | 35 |
| 2025 | 48 |

## Related journals

Liệt kê các journal có nhiều bài liên quan đến keyword đó nhất:

| Journal | Publications |
|---|---:|
| IEEE Access | 15 |
| Nature Machine Intelligence | 9 |
| Expert Systems with Applications | 7 |

## Related publications

Hiển thị danh sách các publication có keyword được chọn, chẳng hạn:

- Title
- Authors
- Publication year
- Journal
- Citation count

Khi chọn publication, có thể tiếp tục điều hướng sang `Publication Detail Screen`.

## Top contributing authors

Thống kê tác giả nào có nhiều publication liên quan đến keyword nhất:

| Xếp hạng | Tác giả | Publications |
|---:|---|---:|
| 1 | Author A | 12 |
| 2 | Author B | 9 |
| 3 | Author C | 7 |

Đây chính là phần **Author analysis** được nhắc đến trong yêu cầu video demo.
