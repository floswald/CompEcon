//sumvec.cpp
#include <iostream>
#include <vector>
int main(){
    std::vector<int> x;
    for (int i=1;i<5;i++){
        x.push_back(i);
    }
    int sum = 0;
    for (std::vector<int>::iterator i=x.begin();i!=x.end();i++){
        sum += *i;
    }
    std::cout << "sum is " << sum << std::endl;
}