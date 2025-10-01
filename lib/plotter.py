# класс для построения графиков с помощью matplotlib
import matplotlib.pyplot as plt
import os


class Plotter:

    def __init__(self, output_dir="output"):
        self.output_dir = output_dir

        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        # списки стилей
        self.colors = ['blue', 'red', 'green', 'orange', 'purple', 'brown', 'pink', 'gray']
        self.line_styles = ['-', '--', '-.', ':', '-', '--', '-.', ':']  # сплошная, пунктир, штрих-пунктир, точки
        self.markers = ['o', 's', '^', 'v', 'D', '*', 'p', 'h']  # круг, квадрат, треугольники, ромб, звезда, пятиугольник, шестиугольник
    # функция для создания и сохранения графика
    def create_plot(self, data, x_values=None, title="График", x_label="X", y_label="Y",
                   filename="plot", save_png=True):
        plt.figure(figsize=(10, 6))

        # Определяем максимальное количество точек для маркеров
        max_points = 0
        if data:
            max_points = max(len(values) for values in data.values())
        show_markers = max_points < 10

        for i, (label, y_values) in enumerate(data.items()):
            if x_values is None:
                x_vals = list(range(len(y_values)))
            else:
                x_vals = x_values[:len(y_values)]

            color = self.colors[i % len(self.colors)]
            line_style = self.line_styles[i % len(self.line_styles)]
            marker = self.markers[i % len(self.markers)] if show_markers else None

            plt.plot(x_vals, y_values,
                    color=color,
                    linestyle=line_style,
                    marker=marker,
                    label=label,
                    linewidth=2,
                    markersize=8 if show_markers else 0)

        plt.title(title, fontsize=14, fontweight='bold')
        plt.xlabel(x_label, fontsize=12)
        plt.ylabel(y_label, fontsize=12)

        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.tight_layout()

        saved_files = []

        if save_png:
            png_path = os.path.join(self.output_dir, f"{filename}.png")
            plt.savefig(png_path, dpi=300, bbox_inches='tight')
            saved_files.append(png_path)
            print(f"Сохранён PNG: {png_path}")

        plt.close()

        return saved_files
