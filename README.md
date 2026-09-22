# DocDigitales Interview Project

Thanks for being interested to work at DocDigitales. This repo was built to test how you build applications and how you would fit in working with the team.  If you'd like to learn more about our product please visit our [website](https://docdigitales.com/).

## Setup

Please go ahead and clone this repo and run `bin/setup` to get everything up and running. Before you start, you should have:

* Ruby 3.1.2

We use the following software versions (if you have previous releases and they work well there's no need to update):

* MySQL 5.7
* Redis 7
* Node 18.12.1
* Yarn 1.22.19

The setup process will install dependencies, and automatically configure the database for your interview.  If you run into any issues with setup, please reach out to your interview team to ask for assistance.

## First passing spec

Now that your repo is setup, we can start the fun stuff!  First create a new branch off of `main` to develop on. Next go ahead and run `bundle exec rspec`. You should see one failing spec. As a warm up, add _just enough_ code to make this test pass. Then do a git commit.

## Part 1: Adding an Invoice Form

One of the most common pieces of work are invoices created by our customers. We've implemented a number of attributes in the invoice creation, but for this exercise, you're going to add a form requesting just two products and this information: quantity, product, unit price and sub total.

You can see a Invoice PDF example here: public/invoice-sample.pdf

Part 1 of your assignment is to:

- [ ] Create a form with just 2 products
- [ ] Store the products
- [ ] Calculate the resulting taxes and total (see below)
- [ ] Show a message to the user about whether they need additional taxes (see below)

There's lots of other things we can do, but this is the simplest starting point.

### Additional information about the task

The form looks like this:

```
Please add your products and click on Create:

1. Item #1
* Quantity
* Product/Service
* Unit Price
** Amount

2. Item #2
* Quantity
* Product/Service
* Unit Price
** Amount

** Sub Total
** Tax
** Total
```

&ast; You will request this information and store it

** You will calculate these data:
- Amount = quantity * unit price
- Sub Total = sum of amounts
- Tax = 16% of the subtotal
- Total = sub total + tax

A tax would be considered to have a `high` score if it exceeds the amount of $2,000.00. If either product 1 or product 2 is scored as `high`, or if both products are scored as `high`, the user should be shown a message that additional tax should be added. Otherwise the user should be shown a message that additional tax is not needed.


### Git commit and tests

Do as many git commits as you feel are appropriate. If you are familiar with writing rspec tests, you can also add as many tests as you feel are appropriate.

## Part 2: Adding a personalized greeting

As part of the process, we are frequently required to integrate with APIs. For this exercise, we will start with a simple greeting that pulls the customer's name from a third party API.

Part 2 of your assignment is to:

- [ ] Retrieve the customer associated with the current invoice using the REST API described below
- [ ] Add a personalized greeting including the customer's first and last names that's displayed prior to beginning the form from part 1.

*When* I am starting a form
*I want to* see a personalized greeting
*so that* I feel confident that the application is trustworthy.

### Additional information about the task

We will be integrating with a dummy API that returns fake user information. The API can be reached by making a `GET` request to `https://dummyjson.com/users/1`. No authorization is required for the request. A simple example using `curl` can be found below.

```shell
curl 'https://dummyjson.com/users/1'

{
    "id": 1,
    "firstName": "Terry",
    "lastName": "Medhurst",
    "maidenName": "Smitham",
    "age": 50,
    "gender": "male",
    "email": "atuny0@sohu.com",
    "phone": "+63 791 675 8914",
    "username": "atuny0",
    "password": "9uQFF1Lh",
    "birthDate": "2000-12-25",
    ...
}
```

You can assume that the hardcoded `id` stored on the `Customer` model corresponds to the user id to use in the request to the dummy API.

### Git commit and tests

As with part 1, feel free to add as many commits and tests as you feel are appropriate.

## Submitting your work

When you are ready for us to review your work, please create a pull request to the `main` branch containing your commits from part 1 and part 2.
