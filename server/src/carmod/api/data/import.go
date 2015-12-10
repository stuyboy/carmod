package data

/**
 Quick class that uses the diffbot api to take a URL and import parts.
 */

import (
	_ "net/url"
	"log"
	"github.com/diffbot/diffbot-go-client"
	"carmod/api/model"
)

const DIFFBOT_TOKEN = "6a83c3f1b7f51319ad85a2ac80670270"

func ExtractProduct(urlE string) *diffbot.Product {
	opt := &diffbot.Options{
		Fields: "*",
		Timeout: 90000}

	product, err := diffbot.ParseProduct(DIFFBOT_TOKEN, urlE, opt)

	if err != nil {
		if apiErr, ok := err.(*diffbot.Error); ok {
			log.Fatal(apiErr)
		}
		log.Fatal(err)
	}

	return product
}

func ProductToPart(dP *diffbot.Product) *model.Part {
	productZero := dP.Products[0]

	newPart := model.Part{Id:productZero.Sku, Classification:"Part", Brand:productZero.Brand, Model:productZero.Title, ProductCode:productZero.ProductId}

	return &newPart
}