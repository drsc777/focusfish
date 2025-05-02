import SwiftUI

struct HeatmapView: View {
    let data: [Date: Int]
    let maxValue: Int
    let cellSize: CGFloat
    let spacing: CGFloat
    let showMonthLabels: Bool
    
    init(data: [Date: Int], cellSize: CGFloat = 12, spacing: CGFloat = 4, showMonthLabels: Bool = true) {
        self.data = data
        self.cellSize = cellSize
        self.spacing = spacing
        self.showMonthLabels = showMonthLabels
        self.maxValue = data.values.max() ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: showMonthLabels ? 8 : 4) {
                    if showMonthLabels {
                        monthLabelsView
                    }
                    
                    heatmapGridView(width: geometry.size.width)
                }
                .padding(10)
            }
        }
    }
    
    // 拆分为更小的视图组件以提高编译效率
    private var monthLabelsView: some View {
        HStack(spacing: 0) {
            ForEach(getMonthLabels(), id: \.self) { month in
                Text(month)
                    .font(.custom("Menlo", size: 10))
                    .foregroundColor(.gray)
                    .frame(width: (cellSize + spacing) * 4) // 每个月的近似宽度
            }
        }
        .padding(.leading, 20) // 与网格对齐
    }
    
    private func heatmapGridView(width: CGFloat) -> some View {
        HStack(alignment: .top, spacing: spacing) {
            // 星期标签 - 使用固定宽度
            weekdayLabelsView
            
            // 热图内容
            heatmapContentView(availableWidth: width - 25)
        }
    }
    
    private var weekdayLabelsView: some View {
        VStack(spacing: spacing) {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.custom("Menlo", size: 8))
                    .foregroundColor(.gray)
                    .frame(width: 12, height: cellSize)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: 12)
    }
    
    private func heatmapContentView(availableWidth: CGFloat) -> some View {
        let cellsPerRow = Int(availableWidth / (cellSize + spacing))
        let gridDays = getDays()
        let maxRows = 7
        let visibleCells = min(cellsPerRow * maxRows, gridDays.count)
        
        // 获取当前日期的索引并计算要显示的日期
        let today = Calendar.current.startOfDay(for: Date())
        let recentDays = getRecentDaysToShow(gridDays: gridDays, today: today, visibleCells: visibleCells, cellsPerRow: cellsPerRow)
        
        return heatmapRows(recentDays: recentDays, cellsPerRow: cellsPerRow)
    }
    
    private func getRecentDaysToShow(gridDays: [Date], today: Date, visibleCells: Int, cellsPerRow: Int) -> [Date] {
        // 尝试找到今天的索引
        if let todayIndex = gridDays.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            let startIndex = max(0, min(gridDays.count - visibleCells, todayIndex - visibleCells/2))
            let endIndex = min(startIndex + visibleCells, gridDays.count)
            return Array(gridDays[startIndex..<endIndex])
        } else {
            // 如果找不到今天，就显示最近的日期
            return Array(gridDays.suffix(visibleCells))
        }
    }
    
    private func heatmapRows(recentDays: [Date], cellsPerRow: Int) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<Int(ceil(Double(recentDays.count) / Double(max(1, cellsPerRow)))), id: \.self) { rowIndex in
                heatmapRow(rowIndex: rowIndex, recentDays: recentDays, cellsPerRow: cellsPerRow)
            }
        }
        .padding(.trailing, 5)
    }
    
    private func heatmapRow(rowIndex: Int, recentDays: [Date], cellsPerRow: Int) -> some View {
        let startIndex = rowIndex * cellsPerRow
        let endIndex = min(startIndex + cellsPerRow, recentDays.count)
        
        return HStack(spacing: spacing) {
            ForEach(startIndex..<endIndex, id: \.self) { index in
                let date = recentDays[index]
                let value = data[date, default: 0]
                heatmapCell(date: date, value: value)
            }
        }
    }
    
    private func heatmapCell(date: Date, value: Int) -> some View {
        Rectangle()
            .fill(getColor(for: value))
            .frame(width: cellSize, height: cellSize)
            .cornerRadius(2)
            .overlay(
                Group {
                    if isToday(date) {
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                            .cornerRadius(2)
                    }
                }
            )
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func getColor(for value: Int) -> Color {
        if value == 0 {
            return Color.gray.opacity(0.2)
        }
        
        let intensity = min(1.0, Double(value) / Double(max(1, maxValue)))
        return Color.black.opacity(0.2 + (intensity * 0.8))
    }
    
    private func getDays() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = 365 // 显示最近365天
        
        return (0..<days).compactMap { day in
            calendar.date(byAdding: .day, value: -day, to: today)
        }.reversed()
    }
    
    private func getMonthLabels() -> [String] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        var months: [String] = []
        var currentDate = calendar.date(byAdding: .month, value: -11, to: today)!
        
        while currentDate <= today {
            months.append(formatter.string(from: currentDate))
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
        
        return months
    }
}

struct HeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [Date: Int] = [:]
        HeatmapView(data: sampleData)
            .frame(height: 300)
            .padding()
    }
} 