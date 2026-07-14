#!/usr/bin/env python3
import sys
import re

try:
    html = sys.stdin.read()

    # 使用正则表达式提取价格盒子
    price_boxes = re.findall(r'<div class="price-box white-box">(.*?)</div>\s*</div>\s*</div>', html, re.DOTALL)

    results = []

    for box in price_boxes:
        # 提取类别名称
        category_match = re.search(r'<a class="nav-item title-h6 active"[^>]*>(.*?)</a>', box)
        category = category_match.group(1).strip() if category_match else 'Unknown'

        # 提取表格中的所有行
        rows = re.findall(r'<tr>(.*?)</tr>', box, re.DOTALL)

        for row in rows:
            # 跳过表头行
            if '<tbody>' in row or 'scope="col"' in row:
                continue

            # 提取所有单元格
            cells = re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', row, re.DOTALL)

            if len(cells) >= 7:
                # 提取产品名称
                product_match = re.search(r'>([^<]+)</a>', cells[0])
                product = product_match.group(1).strip() if product_match else ''

                if not product:
                    continue

                # 清理HTML标签后提取数字
                clean_cell1 = re.sub(r'<[^>]+>', '', cells[1])
                price_match = re.search(r'\$?([0-9,.]+)', clean_cell1)
                current_price = price_match.group(1).replace(',', '') if price_match else '0'

                # 提取涨跌额
                clean_cell2 = re.sub(r'<[^>]+>', '', cells[2])
                change_match = re.search(r'([+-]?[0-9,.]+)', clean_cell2)
                change = change_match.group(1).replace(',', '').replace('+', '') if change_match else '0'

                # 提取涨跌幅
                clean_cell3 = re.sub(r'<[^>]+>', '', cells[3])
                change_pct_match = re.search(r'([+-]?[0-9,.]+)%?', clean_cell3)
                change_pct = change_pct_match.group(1).replace('+', '') if change_pct_match else '0'

                # 提取前收盘价
                clean_cell4 = re.sub(r'<[^>]+>', '', cells[4])
                prev_match = re.search(r'\$?([0-9,.]+)', clean_cell4)
                prev_price = prev_match.group(1).replace(',', '') if prev_match else '0'

                # 提取高点
                clean_cell5 = re.sub(r'<[^>]+>', '', cells[5])
                high_match = re.search(r'\$?([0-9,.]+)', clean_cell5)
                high = high_match.group(1).replace(',', '') if high_match else '0'

                # 提取低点
                clean_cell6 = re.sub(r'<[^>]+>', '', cells[6])
                low_match = re.search(r'\$?([0-9,.]+)', clean_cell6)
                low = low_match.group(1).replace(',', '') if low_match else '0'

                results.append(f'{category}|{product}|{current_price}|{change}|{change_pct}|{prev_price}|{high}|{low}')

    if results:
        for line in results:
            print(line)
    else:
        print('ERROR: No price data found')

except Exception as e:
    print(f'ERROR: {str(e)}')
    import traceback
    traceback.print_exc(file=sys.stderr)
