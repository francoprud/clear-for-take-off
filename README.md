## [GOT a Flight](http://www.delay.ml/) - [Live demo](http://www.delay.ml/demo/)
> ***Flight delay prediction system*** - Solution to the aeronautic Challenge from NASA Space Apps Challenge 2016 Clear for Take Off. It was developed in less than 48hs.

> The client source code is at [this repository](https://github.com/lucaslencinas/spaceapp)

### Collaborators

- [Prudhomme, Franco](https://github.com/francoprud)
- [Raffo, Diego](https://github.com/Enanodr)
- [Lencinas, Lucas](https://github.com/lucaslencinas)

### About GOT a Flight

The potential and complexity of the solution is that the prediction is not based on old statistics, but it is **based on the future and current forecasts** combined with **aviation reports** and multiple factors that influence the weather-related delays, such as the **position of the runways at the airport**, **the number of runways**, **the aircraft specifications**, the **conditions for emergency landings** at the departure airport and the International Aviation Standards and Regulations. 
This information is public; the key point is to combine the correct factors and to generate the most precise rules, and that is why GOT a Flight is being created!

### Improvements (coming soon...)

- **Implement Supervised machine learning techniques** to gain even more accuracy upon each delayed flight predicted. Currently the application is hosted in IBM Bluemix, so a potential candidate could be the Watson service.
- Add **more forecast sources and validate estimates**: detect if the weather prediction of a particular source is not reliable at a particular time.
- Include **historical statistics** and compare them with each prediction to test the results and adjust the estimate if found beneficial.
- Check and **analyze non-weather data** to cover more delay factors, apart from weather conditions.
- Load **more aircraft models and airports** with the corresponding specifications.
- Insert the **flight number instead** of the itinerary.

### TODO

- Refactor of code
- API documentation
