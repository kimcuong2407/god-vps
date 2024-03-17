from operator import index
import pandas as pd
from datetime import datetime
def read_file(file):
    df = pd.read_csv(file, sep='|', encoding='utf-16')    
    df.columns = ['result', 'order type', "entry", 'sl', 'tp', 'start date', 'end date','extra1','extra2','extra3','extra4']
    result_list = df['result'].tolist()
    start_date_list = df['start date'].tolist()
    end_date_list = df['end date'].tolist()
    return result_list, start_date_list, end_date_list
modified_file = read_file('4_Moving_Average_all_signal.txt')


def count_consecutive_losses(results):
    consecutive_losses = {'1': 0, '2': 0, '3': 0, '4': 0, 'extra':0}
    current_streak = 0
    for i in range(len(results)):
        if results[i] == 2:
            current_streak += 1
            if current_streak <= 4 and i < len(results) - 1 and results[i + 1] == 1: 
                consecutive_losses[str(current_streak)] += 1
            elif current_streak >4 and i < len(results) - 1 and results[i + 1] == 1:
                consecutive_losses['extra'] +=1
        else:
            current_streak = 0
    return consecutive_losses

# consecutive_losses = count_consecutive_losses(modified_file)



# consecutive_commands = str(input("Nhập chuỗi lệnh muốn tìm: "))
# following_commands = int(input("Nhập số lệnh tiếp theo muốn kiểm tra: "))

def find_consecutive_command(file, command_string, num_commands, start_date_str, end_date_str):
    my_list = [int(char) for char in str(command_string)]
    count = 0
    risk = -1
    reward = 1
    results = []
    def is_in_results(rr, results):
            for result in results:
                if result['RR'] == rr:
                    return True
            return False
    for i in range(len(file)):
        index_of_real_trade = i + len(my_list)
        if file[i:i + len(my_list)] == my_list and i < len(file) - len(my_list) and index_of_real_trade < len(file):
            following_list = [(file[index_of_real_trade])]
            index_of_end_date = index_of_real_trade
            while len(following_list) < num_commands and index_of_real_trade < len(file):
                start_date_desird = datetime.strptime(start_date_str[index_of_real_trade], '%Y.%m.%d %H:%M:%S')
                end_date_current = datetime.strptime(end_date_str[index_of_end_date], '%Y.%m.%d %H:%M:%S')
                if start_date_desird > end_date_current:
                    following_list.append(file[index_of_real_trade])
                    index_of_end_date += (index_of_real_trade - index_of_end_date)
                    index_of_real_trade += 1
                else:
                    index_of_real_trade += 1
            rr_ratio = sum(reward if num == 1 else risk for num in following_list)
            if is_in_results(rr_ratio, results):
                index_of_result = next((index for index, item in enumerate(results) if item["RR"] == rr_ratio), None)
                results[index_of_result]['soLantimDuoc'] += 1
            else:
                count = 1
                results.append({'soLantimDuoc': count, 'RR': rr_ratio})
    return results

test2 = [1, 1, 2, 2, 1, 1,1,2]
start = ['2022.01.03 05:00:00', '2022.01.03 12:00:00', '2022.01.03 16:00:00', '2022.01.03 17:00:00', '2022.01.04 18:00:00', '2022.01.04 19:00:00', '2022.01.05 05:00:00', '2022.01.05 07:00:00',]
end = ['2022.01.03 17:00:00', '2022.01.03 17:00:00', '2022.01.03 17:00:00', '2022.01.03 18:00:00', '2022.01.05 15:00:00', '2022.01.04 22:00:00', '2022.01.05 11:00:00', '2022.01.05 17:00:00',]

consecutive_commands = 11211212
following_commands = 2

output = find_consecutive_command(modified_file[0], consecutive_commands, following_commands, modified_file[1], modified_file[2])

print(output)

# tìm kết quả của một chuỗi lệnh bất kì khi gặp: 
# input1: chuỗi lệnh, 21212122112 |||| xog cái kia thì làm cái này check trong 10 lệnh trước đó RR bằng -10
# input2: số lệnh muốn kiểm tra 
#  trả về 1
# [{soLantimDuoc: 2, RR: -3}, {soLantimDuoc: 2, RR: -3}]
# trả về 2
# [{soLantimDuoc: 2, RR: -1}, {soLantimDuoc: 2, RR: 1}]
