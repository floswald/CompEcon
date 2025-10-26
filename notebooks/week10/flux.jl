# fit a straight line


using Flux

actual(x) = 4x + 2


# get trainging and testing data
x_train, x_test = hcat(0:5...), hcat(6:10...)

y_train, y_test = actual.(x_train), actual.(x_test)



# build a model
model = Dense(1 => 1)

model.weight
model.bias

# can make predictions
predict = Dense(1 => 1)

# poor predictions
predict(x_train)

# to evaulate predictions, need a loss function
using Statistics

loss(model, x, y) = mean(abs2.(model(x) .- y));

loss(predict, x_train, y_train)

# improve predcition!
using Flux: train!
opt = Descent()
data = [(x_train, y_train)]


train!(loss, predict, data, opt)

loss(predict, x_train, y_train)

# went down!
predict.weight, predict.bias

# train many times
for epoch in 1:200
    train!(loss, predict, data, opt)
end

loss(predict, x_train, y_train)

loss(predict, x_train, y_train)


# verify on testing data
predict(x_test)

y_test